resource kubernetes_namespace metallb_system {
  count = local.enable_metallb ? 1 : 0
  metadata {
    name = "metallb-system"

    labels = {
      app = "metallb"
    }
  }
}

resource kubernetes_manifest metallb_controller_psp {
  count    = local.enable_metallb ? 1 : 0
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "policy/v1beta1"
    "kind"       = "PodSecurityPolicy"
    "metadata" = {
      "labels" = {
        "app" = "metallb"
      }
      "name"      = "controller"
      "namespace" = kubernetes_namespace.metallb_system.0.metadata.0.name
    }
    "spec" = {
      "allowPrivilegeEscalation"        = false
      "allowedCapabilities"             = []
      "allowedHostPaths"                = []
      "defaultAddCapabilities"          = []
      "defaultAllowPrivilegeEscalation" = false
      "fsGroup" = {
        "ranges" = [
          {
            "max" = 65535
            "min" = 1
          },
        ]
        "rule" = "MustRunAs"
      }
      "hostIPC"                = false
      "hostNetwork"            = false
      "hostPID"                = false
      "privileged"             = false
      "readOnlyRootFilesystem" = true
      "requiredDropCapabilities" = [
        "ALL",
      ]
      "runAsUser" = {
        "ranges" = [
          {
            "max" = 65535
            "min" = 1
          },
        ]
        "rule" = "MustRunAs"
      }
      "seLinux" = {
        "rule" = "RunAsAny"
      }
      "supplementalGroups" = {
        "ranges" = [
          {
            "max" = 65535
            "min" = 1
          },
        ]
        "rule" = "MustRunAs"
      }
      "volumes" = [
        "configMap",
        "secret",
        "emptyDir",
      ]
    }
  }
}

resource kubernetes_manifest metallb_speaker_psp {
  count    = local.enable_metallb ? 1 : 0
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "policy/v1beta1"
    "kind"       = "PodSecurityPolicy"
    "metadata" = {
      "labels" = {
        "app" = "metallb"
      }
      "name"      = "speaker"
      "namespace" = kubernetes_namespace.metallb_system.0.metadata.0.name
    }
    "spec" = {
      "allowPrivilegeEscalation" = false
      "allowedCapabilities" = [
        "NET_ADMIN",
        "NET_RAW",
        "SYS_ADMIN",
      ]
      "allowedHostPaths"                = []
      "defaultAddCapabilities"          = []
      "defaultAllowPrivilegeEscalation" = false
      "fsGroup" = {
        "rule" = "RunAsAny"
      }
      "hostIPC"     = false
      "hostNetwork" = true
      "hostPID"     = false
      "hostPorts" = [
        {
          "max" = 7472
          "min" = 7472
        },
      ]
      "privileged"             = true
      "readOnlyRootFilesystem" = true
      "requiredDropCapabilities" = [
        "ALL",
      ]
      "runAsUser" = {
        "rule" = "RunAsAny"
      }
      "seLinux" = {
        "rule" = "RunAsAny"
      }
      "supplementalGroups" = {
        "rule" = "RunAsAny"
      }
      "volumes" = [
        "configMap",
        "secret",
        "emptyDir",
      ]
    }
  }
}

resource kubernetes_service_account metallb_controller {
  count = local.enable_metallb ? 1 : 0
  metadata {
    name      = "controller"
    namespace = kubernetes_namespace.metallb_system.0.metadata.0.name
    labels = {
      "app" = "metallb"
    }
  }
  automount_service_account_token = true
}

resource kubernetes_service_account metallb_speaker {
  count = local.enable_metallb ? 1 : 0
  metadata {
    name      = "speaker"
    namespace = kubernetes_namespace.metallb_system.0.metadata.0.name
    labels = {
      "app" = "metallb"
    }
  }
  automount_service_account_token = true
}

resource kubernetes_cluster_role metallb_controller {
  count = local.enable_metallb ? 1 : 0
  metadata {
    name = "metallb-system:controller"

    labels = {
      app = "metallb"
    }
  }

  rule {
    verbs      = ["get", "list", "watch", "update"]
    api_groups = [""]
    resources  = ["services"]
  }

  rule {
    verbs      = ["update"]
    api_groups = [""]
    resources  = ["services/status"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs          = ["use"]
    api_groups     = ["policy"]
    resources      = ["podsecuritypolicies"]
    resource_names = ["controller"]
  }
}

resource kubernetes_cluster_role metallb_speaker {
  count = local.enable_metallb ? 1 : 0
  metadata {
    name = "metallb-system:speaker"

    labels = {
      app = "metallb"
    }
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["services", "endpoints", "nodes"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs          = ["use"]
    api_groups     = ["policy"]
    resources      = ["podsecuritypolicies"]
    resource_names = ["speaker"]
  }
}

resource kubernetes_role config_watcher {
  count = local.enable_metallb ? 1 : 0
  metadata {
    name      = "config-watcher"
    namespace = kubernetes_namespace.metallb_system.0.metadata.0.name

    labels = {
      app = "metallb"
    }
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["configmaps"]
  }
}

resource kubernetes_role pod_lister {
  count = local.enable_metallb ? 1 : 0
  metadata {
    name      = "pod-lister"
    namespace = kubernetes_namespace.metallb_system.0.metadata.0.name

    labels = {
      app = "metallb"
    }
  }

  rule {
    verbs      = ["list"]
    api_groups = [""]
    resources  = ["pods"]
  }
}

resource kubernetes_cluster_role_binding metallb_controller {
  count = local.enable_metallb ? 1 : 0
  metadata {
    name = kubernetes_cluster_role.metallb_controller.0.metadata.0.name

    labels = {
      app = "metallb"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.metallb_controller.0.metadata.0.name
    namespace = kubernetes_service_account.metallb_controller.0.metadata.0.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.metallb_controller.0.metadata.0.name
  }
}

resource kubernetes_cluster_role_binding metallb_speaker {
  count = local.enable_metallb ? 1 : 0
  metadata {
    name = kubernetes_cluster_role.metallb_speaker.0.metadata.0.name

    labels = {
      app = "metallb"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.metallb_speaker.0.metadata.0.name
    namespace = kubernetes_service_account.metallb_speaker.0.metadata.0.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.metallb_speaker.0.metadata.0.name
  }
}

resource kubernetes_role_binding config_watcher {
  count = local.enable_metallb ? 1 : 0
  metadata {
    name      = kubernetes_role.config_watcher.0.metadata.0.name
    namespace = kubernetes_namespace.metallb_system.0.metadata.0.name

    labels = {
      app = "metallb"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.metallb_controller.0.metadata.0.name
    namespace = kubernetes_service_account.metallb_controller.0.metadata.0.namespace
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.metallb_speaker.0.metadata.0.name
    namespace = kubernetes_service_account.metallb_speaker.0.metadata.0.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.config_watcher.0.metadata.0.name
  }
}

resource kubernetes_role_binding pod_lister {
  count = local.enable_metallb ? 1 : 0
  metadata {
    name      = kubernetes_role.pod_lister.0.metadata.0.name
    namespace = kubernetes_namespace.metallb_system.0.metadata.0.name

    labels = {
      app = "metallb"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.metallb_speaker.0.metadata.0.name
    namespace = kubernetes_service_account.metallb_speaker.0.metadata.0.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.pod_lister.0.metadata.0.name
  }
}

resource kubernetes_daemonset metallb_speaker {
  count = local.enable_metallb ? 1 : 0
  metadata {
    name      = "speaker"
    namespace = kubernetes_namespace.metallb_system.0.metadata.0.name
    labels = {
      app       = "metallb"
      component = "speaker"
    }
  }
  spec {
    selector {
      match_labels = {
        app       = "metallb"
        component = "speaker"
      }
    }
    template {
      metadata {
        labels = {
          app       = "metallb"
          component = "speaker"
        }
        annotations = {
          "prometheus.io/port"   = "7472"
          "prometheus.io/scrape" = "true"
        }
      }
      spec {
        container {
          name  = "speaker"
          image = local.metallb_speaker_image
          args  = ["--port=7472", "--config=config"]
          port {
            name           = "monitoring"
            container_port = 7472
          }
          env {
            name = "METALLB_NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }
          env {
            name = "METALLB_HOST"
            value_from {
              field_ref {
                field_path = "status.hostIP"
              }
            }
          }
          env {
            name = "METALLB_ML_BIND_ADDR"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }
          env {
            name  = "METALLB_ML_LABELS"
            value = "app=metallb,component=speaker"
          }
          env {
            name = "METALLB_ML_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          env {
            name = "METALLB_ML_SECRET_KEY"
            value_from {
              secret_key_ref {
                name = "memberlist"
                key  = "secretkey"
              }
            }
          }
          resources {
            limits {
              cpu    = "100m"
              memory = "100Mi"
            }
          }
          image_pull_policy = "Always"
          security_context {
            capabilities {
              add  = ["NET_ADMIN", "NET_RAW", "SYS_ADMIN"]
              drop = ["ALL"]
            }
            read_only_root_filesystem = true
          }
        }
        termination_grace_period_seconds = 2
        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }
        service_account_name            = kubernetes_service_account.metallb_speaker.0.metadata.0.name
        automount_service_account_token = true
        host_network                    = true
        toleration {
          key    = "node-role.kubernetes.io/master"
          effect = "NoSchedule"
        }
      }
    }
  }
}

resource kubernetes_deployment metallb_controller {
  count = local.enable_metallb ? 1 : 0
  metadata {
    name      = "controller"
    namespace = kubernetes_namespace.metallb_system.0.metadata.0.name
    labels = {
      app       = "metallb"
      component = "controller"
    }
  }
  spec {
    selector {
      match_labels = {
        app       = "metallb"
        component = "controller"
      }
    }
    template {
      metadata {
        labels = {
          app       = "metallb"
          component = "controller"
        }
        annotations = {
          "prometheus.io/port"   = "7472"
          "prometheus.io/scrape" = "true"
        }
      }
      spec {
        container {
          name  = "controller"
          image = local.metallb_controller_image
          args  = ["--port=7472", "--config=config"]
          port {
            name           = "monitoring"
            container_port = 7472
          }
          resources {
            limits {
              cpu    = "100m"
              memory = "100Mi"
            }
          }
          image_pull_policy = "Always"
          security_context {
            capabilities {
              drop = ["all"]
            }
            read_only_root_filesystem = true
          }
        }
        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }
        service_account_name            = kubernetes_service_account.metallb_controller.0.metadata.0.name
        automount_service_account_token = true
        security_context {
          run_as_user     = 65534
          run_as_non_root = true
        }
      }
    }
    revision_history_limit = 3
  }
}

resource random_password metallb_memberlist {
  count   = local.enable_metallb ? 1 : 0
  length  = 16
  special = false
}

resource kubernetes_secret metallb_memberlist {
  count = local.enable_metallb ? 1 : 0
  metadata {
    name      = "memberlist"
    namespace = kubernetes_namespace.metallb_system.0.metadata.0.name
  }

  data = {
    secretkey = random_password.metallb_memberlist.0.result
  }

  type = "Opaque"
}

resource kubernetes_config_map metallb_config {
  count = local.enable_metallb ? 1 : 0
  metadata {
    name      = "config"
    namespace = kubernetes_namespace.metallb_system.0.metadata.0.name
  }

  data = {
    config = yamlencode(
      {
        address-pools = [
          {
            name      = "default"
            protocol  = "layer2"
            addresses = list(var.metallb_addresses)
          }
        ]
      }
    )
  }
}
