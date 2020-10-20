locals {
  controlplane_ips = compact(
    flatten(
      [
        for type, node in var.nodes : [
          type == "controlplane" ? [for n in node : n.ip] : list("")
        ]
      ]
    )
  )
  enable_addons  = split(",", var.addons)
  enable_dex     = contains(local.enable_addons, "dex")
  enable_gangway = contains(local.enable_addons, "gangway")
  dex_url        = var.dex_url != "" ? var.dex_url : local.enable_dex ? format("%s:32000", module.dns.dex_fqdn) : ""
  oidc_extra_args = {
    oidc-client-id      = "gangway"
    oidc-groups-claim   = "groups"
    oidc-issuer-url     = format("https://%s", local.dex_url)
    oidc-username-claim = "name"
  }
  kube_api_extra_args = local.enable_gangway ? merge(local.oidc_extra_args, var.kube_api_extra_args) : var.kube_api_extra_args
}
