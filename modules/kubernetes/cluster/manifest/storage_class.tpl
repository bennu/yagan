%{ for storage_class in storage_classes ~}
apiVersion: storage.k8s.io/v1
kind: StorageClass
provisioner: kubernetes.io/vsphere-volume
metadata:
  annotations:
%{ if can(storage_class.default) ~}
    storageclass.kubernetes.io/is-default-class: "${storage_class.default}"
%{ endif ~}
%{ if can(storage_class.description) ~}
    kubernetes.io/description: "${storage_class.description}"
%{ endif ~}
  name: ${storage_class.name}
parameters:
%{ if can(storage_class.datastore) ~} 
  datastore: ${storage_class.datastore}
%{ endif ~}
%{ if can(storage_class.fs_type) ~}
  fsType: ${storage_class.fs_type}
%{ endif ~}
%{ if can(storage_class.disk_format) ~}
  diskformat: ${storage_class.disk_format}
%{ endif ~}
%{ if can(storage_class.storage_policy_name) ~}
  storagePolicyName: ${storage_class.storage_policy_name}
%{ endif ~}
%{ if can(storage_class.allow_volume_expansion) ~}
allowVolumeExpansion: ${storage_class.allow_volume_expansion}
%{ endif ~}
reclaimPolicy: %{ if can(storage_class.reclaim_policy) ~}${storage_class.reclaim_policy}%{ else ~}Delete%{ endif }
volumeBindingMode: %{ if can(storage_class.volume_binding_mode) ~}${storage_class.volume_binding_mode}%{ else ~}WaitForFirstConsumer%{ endif }
---
%{ endfor ~}
