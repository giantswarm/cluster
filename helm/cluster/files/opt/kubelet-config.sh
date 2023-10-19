#!/bin/bash

{{- if $.Values.internal.kubeadmConfig.kubelet.gracefulNodeShutdown.shutdownGracePeriod }}
sed -i "s|shutdownGracePeriod: .*|shutdownGracePeriod: {{ $.Values.internal.kubeadmConfig.kubelet.gracefulNodeShutdown.shutdownGracePeriod }}|g" "/var/lib/kubelet/config.yaml"
{{- end }}
{{- if $.Values.internal.kubeadmConfig.kubelet.gracefulNodeShutdown.shutdownGracePeriodCriticalPods }}
sed -i "s|shutdownGracePeriodCriticalPods: .*|shutdownGracePeriodCriticalPods: {{ $.Values.internal.kubeadmConfig.kubelet.gracefulNodeShutdown.shutdownGracePeriodCriticalPods }}|g" "/var/lib/kubelet/config.yaml"
{{- end }}
systemctl restart kubelet
