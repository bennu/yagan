# Addons

This modules deploys recommended addons for a kubernetes cluster, such as:

- Authorization
    - [dex][dex]
    - [gangway][gangway]
- [descheduler][descheduler]
- [kured][kured]
- [nginx ingress controller][nginx-ingress]

# Customization

## General

|Variable|Description|Required|Default|
|:---|---|:---:|:---|
|`enable_addons`|Comma-separated list of to-be enabled addons||`auth,descheduler,ingress,kured`|

## Authorization

|Variable|Description|Required|Default|
|:---|---|:---:|:---|
|`dex_image`|Container image for Dex||`quay.io/dexidp/dex:v2.21.0`|
|`gangway_image`|Container images for Gangway||`gcr.io/heptio-images/gangway:v3.1.0`|
|`auth_domain`|Domain URL or IP for exposing Dex & Gangway|X||
|`dex_key_bits`|Bits length for TLS generation||`4096`|
|`dex_ldap_bind_dn`|LDAP/AD account for Dex|X||
|`dex_ldap_bind_pw`|LDAP/AD account password for Dex|X||
|`dex_ldap_endpoint`|LDAP/AD endpoint for Dex|X||
|`dex_ldap_groupsearch`|Enable LDAP/AD groupsearch||`true`|
|`dex_ldap_groupsearch_basedn`|LDAP/AD domain to fetch groupsearch from|X||
|`dex_ldap_groupsearch_filter`|LDAP/AD filter for groupsearch|X||
|`dex_ldap_groupsearch_groupattr`|LDAP/AD group attribute to fetch from groupsearch|X||
|`dex_ldap_groupsearch_nameattr`|LDAP/AD name attribute to fetch from groupsearch|X||
|`dex_ldap_groupsearch_userattr`|LDAP/AD user attribute to fetch from groupsearch|X||
|`dex_ldap_insecure_no_ssl`|Insecure connection to LDAP/AD server||`true`|
|`dex_ldap_ssl_skip_verify`|Do not verify TLS certs when connection to LDAP/AD server||`true`|
|`dex_ldap_start_tls`|Execute Start/TLS operations||`false`|
|`dex_ldap_usersearch`|Enable LDAP/AD usersearch||`true`|
|`dex_ldap_username_prompt`|Username prompt field for LDAP/AD|X||
|`dex_ldap_usersearch_basedn`|LDAP/AD domain to fetch usersearch from|X||
|`dex_ldap_usersearch_emailattr`|LDAP/AD user attribute to fetch from usersearch|X||
|`dex_ldap_usersearch_filter`|LDAP/AD filter for groupsearch|X||
|`dex_ldap_usersearch_idattr`|LDAP/AD id attribute to fetch from usersearch|X||
|`dex_ldap_usersearch_nameattr`|LDAP/AD name attribute to fetch from usersearch|X||
|`dex_ldap_usersearch_username`|LDAP/AD username to fetch from usersearch|||
|`dex_oauth_skip_approval_screen`|Show approval screen||`false`|
|`dex_tls_expiry_time`|Expiry time for TLS certs in hours||`8760`|
|`gangway_api_server_url`|Kubernetes API-Server URL for Gangway to connect to|||
|`gangway_cluster_name`|Cluster name for Gangway config|X||

## Descheduler

According to [descheduler config][descheduler-config]

|Variable|Description|Required|Default|
|:---|---|:---:|:---|
|`descheduler_image`|Container image for descheduler||`docker.io/bennu/descheduler:0.9.0-72-gd9a77393`|
|`descheduler_low_node_utilization`|Configure descheduler for balancing workloads in the cluster||`true`|
|`descheduler_rm_duplicates`|Cleanup orphan pods||`true`|
|`descheduler_rm_node_affinity_violation`|Ensure that pods violating node affinity are removed from nodes||`true`|
|`descheduler_rm_pods_affinity_violation`|Ensure that pods violating interpod anti-affinity are removed from nodes||`true`|
|`descheduler_rm_taint_violation`|Ensure that pods violating NoSchedule taints on nodes are removed||`true`|
|`target_treshold_cpu`|CPU usage percentage for nodes to evict pods from||`50`|
|`target_treshold_mem`|RAM usage percentage for nodes to evict pods from||`75`|
|`target_treshold_pods`|Pods ammount for nodes to evict pods from||`20`|
|`treshold_cpu`|CPU usage percentage for nodes to allocate pods to||`20`|
|`treshold_mem`|RAM usage percentage for nodes to allocate pods to||`20`|
|`treshold_pods`|Pods ammount for nodes to allocate pods to||`8`|

## Kured

According to [kured config][kured-config]

|Variable|Description|Required|Default|
|:---|---|:---:|:---|
|`kured_image`|Container image for kured||`docker.io/weaveworks/kured:master-f6e4062`|
|`kured_timezone`|Timezone to set in kured||`America/Santiago`|
|`kured_args`|Additional args for kured||See: [`kured_args`](./vars.tf#L12)|

## Nginx ingress controller

According to [ingress config][ingress-config]

|Variable|Description|Required|Default|
|:---|---|:---:|:---|
|`ingress_image`|Container image for nginx ingress controller||`quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.28.0`|
|`ingress_args`|Attach extra config||`[]`|
|`ingress_service_type`|Service type for deploying ingress||`LoadBalancer`|

<!-- Links -->
[descheduler-config]: https://github.com/kubernetes-sigs/descheduler#policy-and-strategies
[descheduler]: https://github.com/kubernetes-sigs/descheduler
[dex]: https://github.com/dexidp/dex
[gangway]: https://github.com/heptiolabs/gangway
[ingress-config]: https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/cli-arguments.md
[kured-config]: https://github.com/weaveworks/kured#configuration
[kured]: https://github.com/weaveworks/kured
[nginx-ingress]: https://github.com/kubernetes/ingress-nginx
