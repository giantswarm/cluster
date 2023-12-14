#!/bin/bash

{{- if $.Values.providerIntegration.kubeadmConfig.kubelet.gracefulNodeShutdown.shutdownGracePeriod }}
sed -i "s|shutdownGracePeriod: .*|shutdownGracePeriod: {{ $.Values.providerIntegration.kubeadmConfig.kubelet.gracefulNodeShutdown.shutdownGracePeriod }}|g" "/var/lib/kubelet/config.yaml"
{{- end }}
{{- if $.Values.providerIntegration.kubeadmConfig.kubelet.gracefulNodeShutdown.shutdownGracePeriodCriticalPods }}
sed -i "s|shutdownGracePeriodCriticalPods: .*|shutdownGracePeriodCriticalPods: {{ $.Values.providerIntegration.kubeadmConfig.kubelet.gracefulNodeShutdown.shutdownGracePeriodCriticalPods }}|g" "/var/lib/kubelet/config.yaml"
{{- end }}
systemctl restart kubelet
