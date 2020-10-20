resource helm_release descheduler {
  count      = local.enable_descheduler ? 1 : 0
  atomic     = true
  chart      = "descheduler-helm-chart"
  name       = "descheduler"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/descheduler/"
  version    = local.descheduler_version
  values = [
    yamlencode(
      {
        cmdOptions = {
          v = 4
        }
        deschedulerPolicy = local.descheduler_policy
        priorityClassName = "system-cluster-critical"
      }
    )
  ]
}
