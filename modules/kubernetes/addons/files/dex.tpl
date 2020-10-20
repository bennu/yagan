issuer: https://${dex_url}
storage:
  type: kubernetes
  config:
    inCluster: true
web:
  # http: 0.0.0.0:32000
  https: 0.0.0.0:32000
  tlsCert: /etc/dex/tls/tls.crt
  tlsKey: /etc/dex/tls/tls.key
  tlsClientCA: /etc/dex/tls/ca.crt
telemetry:
  http: 0.0.0.0:5558
logger:
  level: debug
  format: text
# This is a sample with LDAP as connector.
# Requires a update to fulfill your environment.
connectors:
- type: ldap
  id: ldap
  name: openLDAP
  config:
    host: "${dex_ldap_endpoint}"
    insecureNoSSL: ${dex_ldap_insecure_no_ssl}
    insecureSkipVerify: ${dex_ldap_ssl_skip_verify}
    startTLS: ${dex_ldap_start_tls}
    bindDN: "${dex_ldap_bind_dn}"
    bindPW: "${dex_ldap_bind_pw}"
    usernamePrompt: "${dex_ldap_username_prompt}"
%{if dex_ldap_usersearch ~}
    userSearch:
      baseDN: "${dex_ldap_usersearch_basedn}"
      emailAttr: "${dex_ldap_usersearch_emailattr}"
      filter: "${dex_ldap_usersearch_filter}"
      idAttr: "${dex_ldap_usersearch_idattr}"
      nameAttr: "${dex_ldap_usersearch_nameattr}"
      username: "${dex_ldap_usersearch_username}"
%{ endif ~}
%{if dex_ldap_usersearch ~}
    groupSearch:
      baseDN: "${dex_ldap_groupsearch_basedn}"
      filter: "${dex_ldap_groupsearch_filter}"
      groupAttr: "${dex_ldap_groupsearch_groupattr}"
      nameAttr: "${dex_ldap_groupsearch_nameattr}"
      userAttr: "${dex_ldap_groupsearch_userattr}"
%{ endif ~}
oauth2:
  skipApprovalScreen: ${dex_oauth_skip_approval_screen}
staticClients:
- id: gangway
  redirectURIs:
  - 'https://${gangway_url}/callback'
  name: 'Gangway'
  secret: "${gangway_client_secret}"
#   trustedPeers:
#   - oidc-cli
# - id: oidc-cli
#   public: true
#   redirectURIs:
#   - 'urn:ietf:wg:oauth:2.0:oob'
#   name: 'OIDC CLI'
#   secret: swac7qakes7AvucH8bRucucH
%{ if grafana_url != "" ~}
- id: grafana
  redirectURIs:
  - '${grafana_url}'
  name: 'Grafana'
  secret: "${gangway_client_secret}"
%{ endif ~}
