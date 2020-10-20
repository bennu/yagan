variable api_server_lb { default = [] }
variable main_domain { type = string }
variable main_private { default = false }
variable record_ttl { default = "30" }
variable zone_force_destroy { default = true }
variable zone_prefix { type = string }
