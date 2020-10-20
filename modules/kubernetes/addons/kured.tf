resource helm_release kured {
  count      = local.enable_kured ? 1 : 0
  atomic     = true
  chart      = "kured"
  name       = "kured"
  namespace  = "kube-system"
  repository = "https://weaveworks.github.io/kured/"
  version    = local.kured_version
  values = [
    yamlencode(
      {
        configuration = {
          endTime    = var.kured_end_time
          rebootDays = var.kured_reboot_days
          startTime  = var.kured_start_time
          timeZone   = var.kured_timezone
        }
        podSecurityPolicy = {
          create = true
        }
        priorityClassName = "system-cluster-critical"
      }
    )
  ]
}
