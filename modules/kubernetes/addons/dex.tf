###
# Dex
# Original manifests:
# - https://github.com/dexidp/dex/blob/master/examples/k8s/dex.yaml
###

resource kubernetes_service_account dex {
  count = local.enable_dex ? 1 : 0
  metadata {
    name      = "dex"
    namespace = "kube-system"
    labels = {
      "app" = "dex"
    }
  }

  automount_service_account_token = true
}

resource kubernetes_cluster_role dex {
  count = local.enable_dex ? 1 : 0
  metadata {
    name = "dex"
    labels = {
      "app" = "dex"
    }
  }

  rule {
    api_groups = ["dex.coreos.com"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
    verbs      = ["create"] # To manage its own resources, dex must be able to create customresourcedefinitions
  }
}

resource kubernetes_cluster_role_binding dex {
  count = local.enable_dex ? 1 : 0
  metadata {
    name = "dex"
    labels = {
      "app" = "dex"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.dex.0.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.dex.0.metadata.0.name
    namespace = kubernetes_service_account.dex.0.metadata.0.namespace
  }
}

resource kubernetes_config_map dex {
  count = local.enable_dex ? 1 : 0
  metadata {
    name      = "dex"
    namespace = "kube-system"
    labels = {
      "app" = "dex"
    }
  }

  data = {
    "config.yml" = templatefile(format("%s/files/dex.tpl", path.module), local.dex_config)
  }
}

resource kubernetes_daemonset dex {
  count = local.enable_dex ? 1 : 0
  metadata {
    name      = "dex"
    namespace = "kube-system"
    labels = {
      "app" = "dex"
    }
  }

  spec {
    selector {
      match_labels = {
        "app" = "dex"
      }
    }

    strategy {
      type = "RollingUpdate"
    }

    template {
      metadata {
        labels = {
          "app" = "dex"
        }
      }

      spec {
        automount_service_account_token = true
        priority_class_name             = "system-cluster-critical"
        service_account_name            = kubernetes_service_account.dex.0.metadata.0.name

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "node-role.kubernetes.io/controlplane"
                  operator = "Exists"
                }
              }
            }
          }
        }

        toleration {
          effect   = "NoSchedule"
          key      = "node-role.kubernetes.io/controlplane"
          operator = "Equal"
          value    = "true"
        }

        container {
          name    = "dex"
          image   = local.dex_image
          command = ["/usr/local/bin/dex"]
          args = [
            "serve",
            "/etc/dex/cfg/config.yml",
          ]

          port {
            name           = "https"
            container_port = 32000
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/dex/cfg"
          }

          volume_mount {
            name       = "tls"
            mount_path = "/etc/dex/tls"
          }
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.dex.0.metadata.0.name
            items {
              key  = "config.yml"
              path = "config.yml"
            }
          }
        }

        volume {
          name = "tls"
          secret {
            secret_name = null_resource.default_cert_ready.0.triggers.secret_name
          }
        }
      }
    }
  }
}

resource kubernetes_service dex {
  count = local.enable_dex ? 1 : 0
  metadata {
    name      = "dex"
    namespace = "kube-system"
    labels = {
      "app" = "dex"
    }
  }

  spec {
    type = "NodePort"
    selector = {
      "app" = "dex"
    }

    port {
      name        = "dex"
      port        = 32000
      protocol    = "TCP"
      target_port = "https"
      node_port   = 32000
    }
  }
}
