resource helm_release nginx_ingress {
  depends_on = [local.ingress_deploy_deps]
  count      = local.enable_ingress ? 1 : 0
  atomic     = true
  chart      = "ingress-nginx"
  name       = "ingress-nginx"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = local.ingress_version
  values = [
    yamlencode(
      {
        controller = {
          autoscaling = {
            enabled     = var.ingress_autoscale
            minReplicas = var.ingress_min_replicas
            maxReplicas = var.ingress_max_replicas
          }
          extraArgs = local.ingress_extra_args
          metrics = {
            enabled = var.ingress_metrics_enabled
            serviceMonitor = {
              enabled = var.ingress_service_monitor_enabled
            }
            prometheusRule = {
              enabled = var.ingress_prometheus_rule_enabled
            }
          }
          priorityClassName = "system-cluster-critical"
          service = {
            type = var.ingress_service_type
          }
        }
        defaultBackend = {
          enabled = var.ingress_default_backend_enabled
        }
      }
    )
  ]
}
