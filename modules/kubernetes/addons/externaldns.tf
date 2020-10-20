resource helm_release external_dns {
  count      = local.enable_externaldns ? 1 : 0
  atomic     = true
  chart      = "external-dns"
  name       = "external-dns"
  namespace  = "kube-system"
  repository = "https://charts.bitnami.com/bitnami"
  version    = local.external_dns_version
  set_sensitive {
    name  = "aws.credentials.accessKey"
    value = var.external_dns_access_key
  }
  set_sensitive {
    name  = "aws.credentials.secretKey"
    value = var.external_dns_secret_key
  }
  values = [
    yamlencode(
      {
        provider = "aws"
        aws = {
          region      = var.external_dns_region
          zoneType    = "public"
          preferCNAME = var.external_dns_prefer_cname
        }
        interval          = var.external_dns_interval
        priorityClassName = "system-cluster-critical"
        txtOwnerId        = var.zone_id
        zoneIdFilters     = [var.zone_id]
      }
    )
  ]
}
