###
# Gangway
# Original manifests:
# - https://raw.githubusercontent.com/heptiolabs/gangway/v3.2.0/docs/yaml/01-namespace.yaml
# - https://raw.githubusercontent.com/heptiolabs/gangway/v3.2.0/docs/yaml/02-config.yaml
# - https://raw.githubusercontent.com/heptiolabs/gangway/v3.2.0/docs/yaml/03-deployment.yaml
# - https://raw.githubusercontent.com/heptiolabs/gangway/v3.2.0/docs/yaml/04-service.yaml
# - https://raw.githubusercontent.com/heptiolabs/gangway/v3.2.0/docs/yaml/05-ingress.yaml
###

resource random_string gangway_random_key {
  count   = local.enable_gangway ? 2 : 0
  length  = 32
  special = false
}

resource kubernetes_secret gangway_key {
  count = local.enable_gangway ? 1 : 0
  metadata {
    name      = "gangway-key"
    namespace = "kube-system"
  }

  data = {
    sesssionkey = random_string.gangway_random_key.0.result
  }
}

resource kubernetes_config_map gangway {
  count = local.enable_gangway ? 1 : 0
  metadata {
    name      = "gangway"
    namespace = "kube-system"
    labels = {
      "app" = "gangway"
    }
  }

  data = {
    "gangway.yml" = templatefile(format("%s/files/gangway.tpl", path.module), local.gangway_config)
  }
}

resource kubernetes_daemonset gangway {
  count = local.enable_gangway ? 1 : 0
  metadata {
    name      = "gangway"
    namespace = "kube-system"
    labels = {
      "app" = "gangway"
    }
  }

  spec {
    selector {
      match_labels = {
        "app" = "gangway"
      }
    }

    strategy {
      type = "RollingUpdate"
    }

    template {
      metadata {
        labels = {
          "app" = "gangway"
        }
      }

      spec {
        automount_service_account_token = true
        priority_class_name             = "system-cluster-critical"

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
          name    = "gangway"
          image   = local.gangway_image
          command = ["/bin/gangway"]
          args = [
            "-config",
            "/gangway/gangway.yml",
          ]

          port {
            name           = "http"
            container_port = 8080
            protocol       = "TCP"
          }

          env {
            name  = "GANGWAY_HOST"
            value = "0.0.0.0"
          }

          env {
            name  = "GANGWAY_PORT"
            value = "8080"
          }

          env {
            name = "GANGWAY_SESSION_SECURITY_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.gangway_key.0.metadata.0.name
                key  = "sesssionkey"
              }
            }
          }

          resources {
            requests {
              cpu    = "100m"
              memory = "128Mi"
            }

            limits {
              cpu    = "200m"
              memory = "512Mi"
            }
          }

          volume_mount {
            name       = "gangway"
            mount_path = "/gangway/"
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 8080
            }

            initial_delay_seconds = 20
            timeout_seconds       = 1
            period_seconds        = 60
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 8080
            }

            timeout_seconds   = 1
            period_seconds    = 10
            failure_threshold = 3
          }
        }

        volume {
          name = "gangway"
          config_map {
            name = kubernetes_config_map.gangway.0.metadata.0.name
            items {
              key  = "gangway.yml"
              path = "gangway.yml"
            }
          }
        }
      }
    }
  }
}

resource kubernetes_service gangway {
  count = local.enable_gangway ? 1 : 0
  metadata {
    name      = "gangway"
    namespace = "kube-system"
    labels = {
      "app" = "gangway"
    }
  }

  spec {
    type = "ClusterIP"
    selector = {
      "app" = "gangway"
    }

    port {
      name        = "http"
      port        = 80
      protocol    = "TCP"
      target_port = 8080
    }
  }
}

resource kubernetes_ingress gangway {
  count = local.enable_gangway ? 1 : 0
  metadata {
    name      = "gangway"
    namespace = "kube-system"
    labels = {
      "app" = "gangway"
    }

    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
    }
  }

  spec {
    rule {
      host = var.gangway_url
      http {
        path {
          backend {
            service_name = kubernetes_service.gangway.0.metadata.0.name
            service_port = "http"
          }
        }
      }
    }
  }
}
