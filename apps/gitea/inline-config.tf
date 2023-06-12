resource "kubernetes_secret_v1" "gitea_inline_config" {
  metadata {
    name      = "gitea-inline-config"
    namespace = var.namespace
    labels    = local.common-labels
  }

  data = {
    "_generals_" = ""
    metrics      = "ENABLED=true"
    security     = "INSTALL_LOCK=true"
    service      =  "DISABLE_REGISTRATION=${var.disable-registration}"
    cache        = <<-EOF
ADAPTER=memcache
ENABLED=true
HOST=gitea-memcached.${var.namespace}.svc:11211
    EOF
    database = <<-EOF
DB_TYPE=postgres
HOST=${var.instance}-${var.component}.${var.namespace}.svc:5432
NAME=${var.component}
PASSWD=${data.kubernetes_secret_v1.postgresql_password.data["password"]}
USER=${data.kubernetes_secret_v1.postgresql_password.data["username"]}
    EOF
    repository = <<-EOF
DEFAULT_BRANCH=${var.default-branch}
DEFAULT_PUSH_CREATE_PRIVATE=${var.push-create.private}
ENABLE_PUSH_CREATE_ORG=${var.push-create.org}
ENABLE_PUSH_CREATE_USER=${var.push-create.user}
ROOT=/data/git/gitea-repositories
    EOF
    server = <<-EOF
APP_DATA_PATH=/data
DOMAIN=${var.sub-domain}.${var.domain-name}
ENABLE_PPROF=false
HTTP_PORT=3000
PROTOCOL=http
ROOT_URL=https://${var.sub-domain}.${var.domain-name}
SSH_DOMAIN=${var.sub-domain}.${var.domain-name}
SSH_LISTEN_PORT=${var.ssh-port}
SSH_PORT=${var.ssh-port}
    EOF
    ui = <<-EOF
DEFAULT_THEME=${var.theme}
SHOW_USER_EMAIL=false
THEMES=auto,gitea,arc-green,edge-auto,edge-dark,edge-light,everforest-auto,everforest-dark,everforest-light,gitea-modern,gruvbox-auto,gruvbox-dark,gruvbox-light,gruvbox-material-auto,gruvbox-material-dark,gruvbox-material-light,palenight,soft-era,sonokai-andromeda,sonokai-atlantis,sonokai-espresso,sonokai-maia,sonokai-shusia,sonokai,theme-nord
    EOF
    webhook = <<-EOF
ALLOWED_HOST_LIST=${var.webhook.allowed-hosts}
SKIP_TLS_VERIFY=${var.webhook.skip-tls-verify}
    EOF
  }
}
