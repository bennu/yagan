# The address to listen on. Defaults to 0.0.0.0 to listen on all interfaces.
# Env var: GANGWAY_HOST
# host: 0.0.0.0

# The port to listen on. Defaults to 8080.
# Env var: GANGWAY_PORT
# port: 8080

# Should Gangway serve TLS vs. plain HTTP? Default: false
# Env var: GANGWAY_SERVE_TLS
serveTLS: false

# The public cert file (including root and intermediates) to use when serving
# TLS.
# Env var: GANGWAY_CERT_FILE
# certFile: /etc/gangway/tls/tls.crt

# The private key file when serving TLS.
# Env var: GANGWAY_KEY_FILE
# keyFile: /etc/gangway/tls/tls.key

# The cluster name. Used in UI and kubectl config instructions.
# Env var: GANGWAY_CLUSTER_NAME
clusterName: "${cluster_name}"

# OAuth2 URL to start authorization flow.
# Env var: GANGWAY_AUTHORIZE_URL
authorizeURL: "https://${dex_url}/auth"

# OAuth2 URL to obtain access tokens.
# Env var: GANGWAY_TOKEN_URL
tokenURL: "https://${dex_url}/token"

# Endpoint that provides user profile information [optional]. Not all providers
# will require this.
# Env var: GANGWAY_AUDIENCE
audience: "https://${dex_url}/userinfo"

# Used to specify the scope of the requested Oauth authorization.
scopes: ["openid", "email", "groups", "profile", "offline_access"]

# Where to redirect back to. This should be a URL where gangway is reachable.
# Typically this also needs to be registered as part of the oauth application
# with the oAuth provider.
# Env var: GANGWAY_REDIRECT_URL
redirectURL: "https://${gangway_url}/callback"

# API client ID as indicated by the identity provider
# Env var: GANGWAY_CLIENT_ID
clientID: "gangway"

# API client secret as indicated by the identity provider
# Env var: GANGWAY_CLIENT_SECRET
clientSecret: "${gangway_client_secret}"

# Some identity providers accept an empty client secret, this
# is not generally considered a good idea. If you have to use an
# empty secret and accept the risks that come with that then you can
# set this to true.
#allowEmptyClientSecret: false

# The JWT claim to use as the username. This is used in UI.
# Default is "nickname". This is combined with the clusterName
# for the "user" portion of the kubeconfig.
# Env var: GANGWAY_USERNAME_CLAIM
usernameClaim: "name"

# The JWT claim to use as the email claim. This is used to name the
# "user" part of the config. Default is "email".
# Env var: GANGWAY_EMAIL_CLAIM
# emailClaim: "email"

# The API server endpoint used to configure kubectl
# Env var: GANGWAY_APISERVER_URL
apiServerURL: "${api_server}"

# The path to find the CA bundle for the API server. Used to configure kubectl.
# This is typically mounted into the default location for workloads running on
# a Kubernetes cluster and doesn't need to be set.
# Env var: GANGWAY_CLUSTER_CA_PATH
# cluster_ca_path: "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"

# The path to a root CA to trust for self signed certificates at the Oauth2 URLs
# Env var: GANGWAY_TRUSTED_CA_PATH
#trustedCAPath: /cacerts/rootca.crt

# The path gangway uses to create urls (defaults to "")
# Env var: GANGWAY_HTTP_PATH
#httpPath: "https://GANGWAY_HTTP_PATH"

# The path to find custom HTML templates
# Env var: GANGWAY_CUSTOM_HTTP_TEMPLATES_DIR
#customHTMLTemplatesDir: /custom-templates
