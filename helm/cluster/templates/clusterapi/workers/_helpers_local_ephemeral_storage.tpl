{{/*
    Local instance-store NVMe ephemeral storage.

    "cluster.internal.workers.localEphemeralStorage.enabled" returns the string
    "true" when ANY node pool opts in via `localNvme.enabled`. Delivery is
    cluster-wide (there is no per-pool worker bootstrap hook), so the script is
    rendered once into the worker preKubeadmCommands and self-gates on the
    presence of instance-store NVMe hardware at runtime - it is a no-op on nodes
    (and instance types) without instance store.

    "cluster.internal.workers.localEphemeralStorage.script" renders the bootstrap
    script, parameterized by the cluster-wide values under
    `internal.advancedConfiguration.workers.localEphemeralStorage`.
*/}}
{{- define "cluster.internal.workers.localEphemeralStorage.enabled" -}}
{{- range $name, $config := $.Values.global.nodePools | default $.Values.providerIntegration.workers.defaultNodePools }}
{{- if (($config.localNvme).enabled) }}
{{- print "true" -}}
{{- break -}}
{{- end }}
{{- end }}
{{- end -}}

{{- define "cluster.internal.workers.localEphemeralStorage.script" -}}
#!/usr/bin/env bash
# Self-gating: mount local instance-store NVMe over the kubelet dir, and add a
# nodefs.available disk-eviction backstop. Safe no-op on instance types without
# instance store (e.g. EBS-only families).
# Runs in workers.preKubeadmCommands, i.e. BEFORE `kubeadm join` starts kubelet,
# so the mount path is still empty and safe to mount over, and the kubeadm patch
# under /etc/kubernetes/patches is read afterwards.
set -euo pipefail

MOUNT_PATH="{{ .mountPath }}"
NODEFS_AVAILABLE="{{ .evictionHardNodefsAvailable }}"
PATCH_FILE="/etc/kubernetes/patches/kubeletconfiguration9+merge.yaml"

# Idempotent: bail if the mount path is already a dedicated mount (re-run / reboot).
mountpoint -q "$MOUNT_PATH" && exit 0

# Discover instance-store NVMe by controller model string (AWS Nitro sets this).
# EBS reports "Amazon Elastic Block Store"; instance store reports the string below.
mapfile -t DISKS < <(for d in /dev/nvme*n1; do
  [ -e "$d" ] || continue
  nvme id-ctrl "$d" 2>/dev/null | grep -q "Amazon EC2 NVMe Instance Storage" && echo "$d"
done)

# No instance store on this instance type -> do nothing, node boots normally.
[ "${#DISKS[@]}" -eq 0 ] && exit 0

if [ "${#DISKS[@]}" -gt 1 ]; then
  # Stripe all instance-store disks for full capacity + throughput.
  mdadm --create /dev/md/instancestore --level=0 --force \
        --raid-devices="${#DISKS[@]}" "${DISKS[@]}"
  mdadm --detail --scan >> /etc/mdadm.conf        # reassemble on reboot
  DEV=/dev/md/instancestore
else
  DEV="${DISKS[0]}"
fi

mkfs.xfs -f -L kubelet-nvme "$DEV"
mkdir -p "$MOUNT_PATH"

# Persist across reboots; ordered after the existing /var/lib (xvdd) mount.
# nofail: if the disk is ever absent (stop/start wipes instance store) the node still boots.
echo "LABEL=kubelet-nvme ${MOUNT_PATH} xfs defaults,noatime,nofail,x-systemd.requires-mounts-for=/var/lib 0 2" >> /etc/fstab
systemctl daemon-reload
mount "$MOUNT_PATH"

# Node-level disk-eviction backstop. GS's kubelet config specifies evictionHard
# (memory.available, imagefs.available) which, without mergeDefaultEvictionSettings,
# replaces kubelet's built-in nodefs.available<10% default - leaving no disk backstop.
# This +merge strategic-merge patch adds nodefs.available back without disturbing the
# existing keys. Skipped when the threshold is empty.
if [ -n "$NODEFS_AVAILABLE" ]; then
  mkdir -p "$(dirname "$PATCH_FILE")"
  cat > "$PATCH_FILE" <<EOF
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
evictionHard:
  nodefs.available: "${NODEFS_AVAILABLE}"
EOF
fi
{{- end -}}
