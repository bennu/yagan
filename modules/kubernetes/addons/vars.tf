variable addons { default = "cert-manager,descheduler,dex,externaldns,gangway,ingress,kured,metallb" }

# ingress
variable ingress_autoscale { default = true }
variable ingress_default_backend_enabled { default = true }
variable ingress_extra_args { default = {} }
variable ingress_max_replicas { default = 5 }
variable ingress_metrics_enabled { default = false }
variable ingress_min_replicas { default = 1 }
variable ingress_prometheus_rule_enabled { default = false }
variable ingress_service_monitor_enabled { default = false }
variable ingress_service_type { default = "LoadBalancer" }

# kured
variable kured_start_time { default = "22:00" }
variable kured_end_time { default = "6:00" }
variable kured_reboot_days { default = ["mon", "sat", "sun"] }
variable kured_timezone { default = "America/Santiago" }

# descheduler LowNodeUtilization config
variable descheduler_low_node_utilization { default = true }
variable descheduler_rm_duplicates { default = true }
variable descheduler_rm_node_affinity_violation { default = true }
variable descheduler_rm_pods_affinity_violation { default = true }
variable descheduler_rm_taint_violation { default = true }

## treshold for watching nodes with high utilization
variable target_treshold_cpu { default = 50 }
variable target_treshold_mem { default = 75 }
variable target_treshold_pods { default = 75 }

## treshold for watching nodes with low utilization
variable treshold_cpu { default = 20 }
variable treshold_mem { default = 20 }
variable treshold_pods { default = 20 }

# auth-related vars
variable dex_ldap_bind_dn { default = "" }
variable dex_ldap_bind_pw { default = "" }
variable dex_ldap_endpoint { default = "" }
variable dex_ldap_groupsearch { default = true }
variable dex_ldap_groupsearch_basedn { default = "" }
variable dex_ldap_groupsearch_filter { default = "" }
variable dex_ldap_groupsearch_groupattr { default = "" }
variable dex_ldap_groupsearch_nameattr { default = "" }
variable dex_ldap_groupsearch_userattr { default = "" }
variable dex_ldap_insecure_no_ssl { default = true }
variable dex_ldap_ssl_skip_verify { default = true }
variable dex_ldap_start_tls { default = false }
variable dex_ldap_username_prompt { default = "" }
variable dex_ldap_usersearch { default = true }
variable dex_ldap_usersearch_basedn { default = "" }
variable dex_ldap_usersearch_emailattr { default = "" }
variable dex_ldap_usersearch_filter { default = "" }
variable dex_ldap_usersearch_idattr { default = "" }
variable dex_ldap_usersearch_nameattr { default = "" }
variable dex_ldap_usersearch_username { default = "" }
variable dex_oauth_skip_approval_screen { default = true }
variable dex_url { default = "" }
variable gangway_api_server_url { default = "" }
variable gangway_cluster_name { default = "" }
variable gangway_url { default = "" }
variable grafana_url { default = "" }

# externaldns vars
variable dns_zone { default = "" }
variable external_dns_access_key { default = "" }
variable external_dns_interval { default = "30s" }
variable external_dns_region { default = "us-east-1" }
variable external_dns_prefer_cname { default = false }
variable external_dns_secret_key { default = "" }

# cert-manager
variable acme_email { default = "" }
variable acme_server { default = "production" }
variable cert_manager_access_key { default = "" }
variable cert_manager_aws_region { default = "us-east-1" }
variable cert_manager_secret_key { default = "" }
variable zone_id { default = "" }

# metallb
variable metallb_addresses { default = "" }
