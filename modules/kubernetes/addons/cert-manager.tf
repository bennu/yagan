resource kubernetes_namespace cert_manager {
  count = local.enable_cert_manager ? 1 : 0
  metadata {
    name = "cert-manager"
  }
}

resource helm_release cert_manager {
  count      = local.enable_cert_manager ? 1 : 0
  atomic     = true
  chart      = "cert-manager"
  name       = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.0.metadata.0.name
  repository = "https://charts.jetstack.io"
  version    = local.cert_manager_version
  values = [
    yamlencode(
      {
        installCRDs = true
      }
    )
  ]
}

resource kubernetes_secret route53_cert_manager_credentials {
  count = local.enable_cert_manager ? 1 : 0
  metadata {
    name      = "route53-cert-manager-credentials"
    namespace = kubernetes_namespace.cert_manager.0.metadata.0.name
  }

  data = {
    secret_key = var.cert_manager_secret_key
  }
}

resource null_resource cluster_issuer {
  depends_on = [helm_release.cert_manager, kubernetes_secret.route53_cert_manager_credentials]
  count      = local.enable_cert_manager ? 1 : 0

  triggers = {
    issuer = yamlencode(
      {
        apiVersion = "cert-manager.io/v1alpha2"
        kind       = "ClusterIssuer"
        metadata = {
          name = "letsencrypt"
        }
        spec = {
          acme = {
            email  = var.acme_email
            server = local.acme_server
            privateKeySecretRef = {
              name = "acme-cluster-issuer"
            }
            solvers = [
              {
                dns01 = {
                  route53 = {
                    hostedZoneID = var.zone_id
                    region       = var.cert_manager_aws_region
                    accessKeyID  = var.cert_manager_access_key
                    secretAccessKeySecretRef = {
                      name = local.cert_manager_secret_name
                      key  = "secret_key"
                    }
                  }
                }
                selector = {
                  dnsZones = [
                    var.dns_zone
                  ]
                }
              }
            ]
          }
        }
      }

    )
  }

  provisioner "local-exec" {
    command     = format("echo '%s'|kubectl apply -f -", self.triggers.issuer)
    interpreter = ["/usr/bin/env", "bash", "-c"]
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "kubectl delete clusterissuers.cert-manager.io letsencrypt"
    interpreter = ["/usr/bin/env", "bash", "-c"]
  }
}

resource null_resource default_cert {
  depends_on = [helm_release.cert_manager, kubernetes_secret.route53_cert_manager_credentials, null_resource.cluster_issuer]
  count      = local.enable_cert_manager ? 1 : 0

  triggers = {
    default_cert = yamlencode(
      {
        apiVersion = "cert-manager.io/v1alpha2"
        kind       = "Certificate"
        metadata = {
          name      = "default-cert"
          namespace = "kube-system"
        }
        spec = {
          secretName  = "default-cert"
          duration    = "2160h"
          renewBefore = "360h"
          issuerRef = {
            name = "letsencrypt"
            kind = "ClusterIssuer"
          }
          dnsNames = [
            local.dns_name
          ]
        }
      }
    )
  }

  provisioner "local-exec" {
    command     = format("echo '%s'|kubectl apply -f -", self.triggers.default_cert)
    interpreter = ["/usr/bin/env", "bash", "-c"]
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "kubectl delete certificates.cert-manager.io default-cert -n kube-system"
    interpreter = ["/usr/bin/env", "bash", "-c"]
  }
}

resource null_resource default_cert_ready {
  depends_on = [helm_release.cert_manager, kubernetes_secret.route53_cert_manager_credentials, null_resource.cluster_issuer, null_resource.default_cert]
  count      = local.enable_cert_manager ? 1 : 0

  triggers = {
    default_cert = "kube-system/default-cert"
    secret_name  = "default-cert"
  }

  provisioner "local-exec" {
    command     = "until [[ $(kubectl get certificate default-cert -n kube-system -o=jsonpath='{.status.conditions[0].type}'|sed 's/\\x1b\\[[0-9;]*[mGKF]//g') == 'Ready' && $(kubectl get certificate default-cert -n kube-system -o=jsonpath='{.status.conditions[0].status}'|sed 's/\\x1b\\[[0-9;]*[mGKF]//g') == 'True' ]]; do echo 'Waiting for default-cert to be ready...' && sleep 5; done && echo 'default-cert ready'"
    interpreter = ["/usr/bin/env", "bash", "-c"]
  }
}
