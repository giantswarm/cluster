{{- define "cluster.internal.workers.kubeadmConfig.spec.hash" -}}
{{ $spec := include "cluster.internal.workers.kubeadmConfig.spec" $ }}{{ regexReplaceAll `^\s*#.*$` $spec "" | sha256sum | trunc 5 }}
{{- end -}}

{{- define "cluster.internal.workers.kubeadmConfig.spec"}}
format: ignition
ignition:
  {{- include "cluster.internal.workers.kubeadm.ignition" $ | indent 4 }}
joinConfiguration:
  {{- include "cluster.internal.workers.kubeadm.joinConfiguration" $ | indent 4 }}
preKubeadmCommands:
{{- include "cluster.internal.workers.kubeadm.preKubeadmCommands" $ | indent 2 }}
{{- $postKubeadmCommands := include "cluster.internal.workers.kubeadm.postKubeadmCommands" $ }}
{{- if $postKubeadmCommands }}
postKubeadmCommands:
{{- $postKubeadmCommands | indent 2 }}
{{- end }}
{{- $users := include "cluster.internal.kubeadm.users" $ }}
{{- if $users }}
users:
{{- $users | indent 2 }}
{{- end }}
files:
{{- include "cluster.internal.workers.kubeadm.files" $ | indent 2 }}
  owner: root:root
{{- end }}
