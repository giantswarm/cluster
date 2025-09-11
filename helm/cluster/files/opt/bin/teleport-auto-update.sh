#!/bin/bash

# Teleport Auto-Update Script for Giant Swarm Clusters
# This script synchronizes the Teleport binary version with the cluster configuration

set -euo pipefail

# Configuration
TELEPORT_BINARY="/opt/bin/teleport"
TELEPORT_CONFIG="/etc/teleport.yaml"
TELEPORT_SERVICE="teleport.service"
BACKUP_DIR="/opt/bin/teleport-backups"
LOG_TAG="teleport-auto-update"
DOWNLOAD_TIMEOUT=300
MAX_RETRIES=3

# Logging function
log() {
    echo "$(date -Iseconds) [$LOG_TAG] $*" | systemd-cat -t "$LOG_TAG"
}

log_error() {
    echo "$(date -Iseconds) [$LOG_TAG] ERROR: $*" | systemd-cat -p err -t "$LOG_TAG"
}

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Function to get current installed version
get_current_version() {
    if [ -x "$TELEPORT_BINARY" ]; then
        "$TELEPORT_BINARY" version | grep "Teleport v" | sed 's/.*Teleport v\([0-9.]*\).*/\1/' || echo "unknown"
    else
        echo "not-installed"
    fi
}

# Function to get proxy address from teleport config
get_proxy_address() {
    if [ -f "$TELEPORT_CONFIG" ]; then
        # Extract proxy_server from YAML config
        grep "proxy_server:" "$TELEPORT_CONFIG" | sed 's/.*proxy_server: *//' | tr -d '\n\r '
    else
        log_error "Teleport config not found: $TELEPORT_CONFIG"
        return 1
    fi
}

# Function to get desired cluster version from Teleport proxy
get_cluster_version() {
    local proxy_addr=$(get_proxy_address)
    
    if [ $? -ne 0 ] || [ -z "$proxy_addr" ]; then
        log_error "Failed to get proxy address from config"
        return 1
    fi
    
    log "Querying Teleport cluster version from: $proxy_addr"
    
    # Try multiple methods to get the cluster version
    local cluster_version=""
    local host=$(echo "$proxy_addr" | cut -d: -f1)
    local port=$(echo "$proxy_addr" | cut -d: -f2)
    
    # Method 1: Query the Teleport Web API ping endpoint
    log "Attempting to query cluster version via Teleport Web API..."
    cluster_version=$(timeout 30 curl -s -k "https://$host:$port/webapi/ping" 2>/dev/null | \
                     sed -n 's/.*"server_version":"\([^"]*\)".*/\1/p' | \
                     sed 's/^v//' | head -1 || echo "")
    
    # Method 2: Try alternative API endpoint
    if [ -z "$cluster_version" ]; then
        log "Attempting to query via alternative API endpoint..."
        cluster_version=$(timeout 30 curl -s -k "https://$host:$port/web/config" 2>/dev/null | \
                         grep -o '"serverVersion":"[^"]*"' | \
                         sed 's/"serverVersion":"//' | \
                         sed 's/"//' | \
                         sed 's/^v//' || echo "")
    fi
    
    # Method 3: Use teleport binary with verbose ping (extracts server version from response)
    if [ -z "$cluster_version" ] && [ -x "$TELEPORT_BINARY" ]; then
        log "Attempting to query cluster version via teleport ping..."
        # Use verbose ping and extract server version from handshake response
        local ping_output=$(timeout 30 "$TELEPORT_BINARY" ping --proxy="$proxy_addr" 2>&1 || echo "")
        if [ -n "$ping_output" ]; then
            # Look for server version in ping output (format may vary)
            cluster_version=$(echo "$ping_output" | grep -i "server version" | \
                             sed 's/.*version[: ]*v*\([0-9][0-9.]*\).*/\1/' | \
                             head -1 || echo "")
        fi
    fi
    
    # Method 4: Try using tsh status (if tsh is available and can connect)
    if [ -z "$cluster_version" ] && command -v tsh >/dev/null 2>&1; then
        log "Attempting to query cluster version via tsh status..."
        # Try to get status from cluster (this requires connection)
        cluster_version=$(timeout 30 tsh status --proxy="$proxy_addr" 2>/dev/null | \
                         grep -i "cluster.*version\|server.*version" | \
                         sed 's/.*version[: ]*v*\([0-9][0-9.]*\).*/\1/' | \
                         head -1 || echo "")
    fi
    
    # Method 5: Try direct HTTPS connection to get server headers
    if [ -z "$cluster_version" ]; then
        log "Attempting to query cluster version via server headers..."
        cluster_version=$(timeout 30 curl -s -k -I "https://$host:$port/" 2>/dev/null | \
                         grep -i "server\|teleport" | \
                         sed 's/.*teleport[\/: ]*v*\([0-9][0-9.]*\).*/\1/i' | \
                         head -1 || echo "")
    fi
    
    # Method 6: Fallback to manual version file (if configured)
    if [ -z "$cluster_version" ] && [ -f "/etc/teleport-target-version" ]; then
        log "Attempting to use manual version override file..."
        cluster_version=$(cat "/etc/teleport-target-version" | tr -d '\n\r ' | head -1)
        if [ -n "$cluster_version" ]; then
            log "Using manual version override: $cluster_version"
        fi
    fi
    
    # Validate version format and return
    if [ -n "$cluster_version" ] && [[ "$cluster_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log "Successfully retrieved cluster version: $cluster_version"
        echo "$cluster_version" | tr -d '\n\r '
        return 0
    else
        log_error "Failed to retrieve valid cluster version from $proxy_addr using all available methods"
        log_error "Attempted methods:"
        log_error "  1. Teleport Web API (/webapi/ping)"
        log_error "  2. Alternative API endpoint (/web/config)"  
        log_error "  3. Teleport ping command output parsing"
        log_error "  4. tsh status command"
        log_error "  5. Server HTTP headers"
        log_error "  6. Manual override file (/etc/teleport-target-version)"
        log_error ""
        log_error "Troubleshooting:"
        log_error "  - Ensure proxy $proxy_addr is accessible"
        log_error "  - Check network connectivity and firewall rules"
        log_error "  - Verify Teleport cluster is running and healthy"
        log_error "  - As fallback, create /etc/teleport-target-version with desired version"
        return 1
    fi
}

# Function to verify binary integrity
verify_binary() {
    local binary_path="$1"
    
    # Basic checks
    if [ ! -f "$binary_path" ]; then
        log_error "Binary not found: $binary_path"
        return 1
    fi
    
    if [ ! -x "$binary_path" ]; then
        log_error "Binary not executable: $binary_path"
        return 1
    fi
    
    # Try to get version - this validates the binary works
    if ! "$binary_path" version >/dev/null 2>&1; then
        log_error "Binary version check failed: $binary_path"
        return 1
    fi
    
    log "Binary verification successful: $binary_path"
    return 0
}

# Function to download Teleport binary
download_teleport() {
    local version="$1"
    local temp_file="/tmp/teleport-${version}"
    local download_url="https://cdn.teleport.dev/teleport-v${version}-linux-amd64-bin.tar.gz"
    local extract_dir="/tmp/teleport-extract-$$"
    
    log "Downloading Teleport v${version} from ${download_url}"
    
    # Clean up any existing temp files
    rm -f "$temp_file" "${temp_file}.tar.gz"
    rm -rf "$extract_dir"
    
    # Download with retries
    for i in $(seq 1 $MAX_RETRIES); do
        if curl -L -o "${temp_file}.tar.gz" --connect-timeout 30 --max-time "$DOWNLOAD_TIMEOUT" "$download_url"; then
            break
        else
            log "Download attempt $i failed, retrying..."
            if [ $i -eq $MAX_RETRIES ]; then
                log_error "Failed to download after $MAX_RETRIES attempts"
                return 1
            fi
            sleep 5
        fi
    done
    
    # Extract the binary
    mkdir -p "$extract_dir"
    if ! tar -xzf "${temp_file}.tar.gz" -C "$extract_dir"; then
        log_error "Failed to extract downloaded archive"
        rm -rf "$extract_dir"
        rm -f "${temp_file}.tar.gz"
        return 1
    fi
    
    # Find the teleport binary in the extracted content
    local extracted_binary=$(find "$extract_dir" -name "teleport" -type f | head -1)
    if [ -z "$extracted_binary" ]; then
        log_error "Teleport binary not found in extracted archive"
        rm -rf "$extract_dir"
        rm -f "${temp_file}.tar.gz"
        return 1
    fi
    
    # Copy to temp location and verify
    cp "$extracted_binary" "$temp_file"
    chmod +x "$temp_file"
    
    if ! verify_binary "$temp_file"; then
        log_error "Downloaded binary verification failed"
        rm -f "$temp_file" "${temp_file}.tar.gz"
        rm -rf "$extract_dir"
        return 1
    fi
    
    # Clean up extraction
    rm -rf "$extract_dir"
    rm -f "${temp_file}.tar.gz"
    
    log "Successfully downloaded and verified Teleport v${version}"
    echo "$temp_file"
}

# Function to backup current binary
backup_current_binary() {
    if [ -x "$TELEPORT_BINARY" ]; then
        local backup_name="teleport-backup-$(date +%Y%m%d-%H%M%S)"
        local backup_path="$BACKUP_DIR/$backup_name"
        
        cp "$TELEPORT_BINARY" "$backup_path"
        log "Backed up current binary to: $backup_path"
        
        # Keep only the 5 most recent backups
        find "$BACKUP_DIR" -name "teleport-backup-*" -type f | sort -r | tail -n +6 | xargs -r rm
        
        echo "$backup_path"
    fi
}

# Function to rollback to previous binary
rollback_binary() {
    local backup_path="$1"
    
    if [ -f "$backup_path" ]; then
        log "Rolling back to backup: $backup_path"
        cp "$backup_path" "$TELEPORT_BINARY"
        chmod +x "$TELEPORT_BINARY"
        
        if verify_binary "$TELEPORT_BINARY"; then
            log "Rollback successful"
            return 0
        else
            log_error "Rollback verification failed"
            return 1
        fi
    else
        log_error "Backup file not found for rollback: $backup_path"
        return 1
    fi
}

# Function to restart Teleport service safely
restart_teleport_service() {
    log "Restarting Teleport service..."
    
    # Check if service is active before restart
    if systemctl is-active --quiet "$TELEPORT_SERVICE"; then
        if systemctl restart "$TELEPORT_SERVICE"; then
            # Wait a bit for service to start
            sleep 5
            
            # Verify service is running
            if systemctl is-active --quiet "$TELEPORT_SERVICE"; then
                log "Teleport service restarted successfully"
                return 0
            else
                log_error "Teleport service failed to start after restart"
                return 1
            fi
        else
            log_error "Failed to restart Teleport service"
            return 1
        fi
    else
        log "Teleport service was not active, attempting to start..."
        if systemctl start "$TELEPORT_SERVICE"; then
            log "Teleport service started successfully"
            return 0
        else
            log_error "Failed to start Teleport service"
            return 1
        fi
    fi
}

# Test function to validate version extraction
test_version_extraction() {
    local test_json='{"auth":{"type":"github"},"server_version":"17.7.2","cluster_name":"test"}'
    local extracted=$(echo "$test_json" | sed -n 's/.*"server_version":"\([^"]*\)".*/\1/p' | sed 's/^v//')
    
    if [ "$extracted" = "17.7.2" ]; then
        log "Version extraction test: PASSED (extracted: $extracted)"
        return 0
    else
        log_error "Version extraction test: FAILED (extracted: '$extracted', expected: '17.7.2')"
        return 1
    fi
}

# Main update logic
main() {
    local dry_run=false
    local test_mode=false
    
    # Check for flags
    if [ "${1:-}" = "--dry-run" ]; then
        dry_run=true
        log "Starting Teleport auto-update check (DRY RUN mode)..."
    elif [ "${1:-}" = "--test" ]; then
        test_mode=true
        log "Running Teleport auto-update tests..."
        test_version_extraction
        exit $?
    else
        log "Starting Teleport auto-update check..."
    fi
    
    # Get current and desired versions
    local current_version=$(get_current_version)
    
    log "Getting cluster version from Teleport proxy..."
    local cluster_version=$(get_cluster_version)
    
    if [ $? -ne 0 ]; then
        log_error "Failed to query cluster version from Teleport proxy"
        log_error "This could be due to network connectivity issues or proxy unavailability"
        exit 1
    fi
    
    log "Current version: $current_version"
    log "Cluster version: $cluster_version"
    
    # Check if update is needed
    if [ "$current_version" = "$cluster_version" ]; then
        log "Teleport is already at the desired version ($cluster_version)"
        exit 0
    fi
    
    # Show update information
    log "Update needed: $current_version -> $cluster_version"
    
    # Exit early if dry-run
    if [ "$dry_run" = true ]; then
        log "DRY RUN: Would update Teleport from v$current_version to v$cluster_version"
        log "DRY RUN: Exiting without making changes"
        exit 0
    fi
    
    # Perform actual update
    
    # Download new binary
    local temp_binary=$(download_teleport "$cluster_version")
    if [ $? -ne 0 ]; then
        log_error "Failed to download Teleport v$cluster_version"
        exit 1
    fi
    
    # Backup current binary
    local backup_path=$(backup_current_binary)
    
    # Replace binary
    log "Installing new Teleport binary..."
    cp "$temp_binary" "$TELEPORT_BINARY"
    chmod +x "$TELEPORT_BINARY"
    
    # Verify new binary
    if ! verify_binary "$TELEPORT_BINARY"; then
        log_error "New binary verification failed, rolling back..."
        if [ -n "$backup_path" ]; then
            rollback_binary "$backup_path"
        fi
        rm -f "$temp_binary"
        exit 1
    fi
    
    # Clean up temp file
    rm -f "$temp_binary"
    
    # Restart Teleport service
    if ! restart_teleport_service; then
        log_error "Service restart failed, rolling back..."
        if [ -n "$backup_path" ]; then
            rollback_binary "$backup_path"
            restart_teleport_service
        fi
        exit 1
    fi
    
    # Verify final version
    local new_version=$(get_current_version)
    if [ "$new_version" = "$cluster_version" ]; then
        log "Update successful: Teleport updated to v$new_version"
    else
        log_error "Update verification failed: expected $cluster_version, got $new_version"
        exit 1
    fi
}

# Run main function
main "$@"

