
locals {
  base-dn = format("dc=%s", join(",dc=", split(".", format("%s.%s", var.sub-domain, var.domain-name))))
  base-group-dn = format("ou=groups,%s", local.base-dn)
  base-user-dn = format("ou=users,%s", local.base-dn)
  authentik-token = data.kubernetes_secret_v1.authentik.data["AUTHENTIK_BOOTSTRAP_TOKEN"]
}
resource "kubernetes_manifest" "gitea_ldap" {
  manifest = {
    apiVersion = "secretgenerator.mittwald.de/v1alpha1"
    kind       = "StringSecret"
    metadata = {
      name      = "${var.component}-ldap"
      namespace = var.namespace
      labels    = local.common-labels
    }
    spec = {
      forceRegenerate = false,
      data = {
        bindDn = "cn=ldapsearch,${local.base-user-dn}"
        user-search-base = local.base-user-dn
        user-filter = "(&(|(memberof=cn=gitea_admin,${local.base-group-dn})(memberof=cn=gitea_users,${local.base-group-dn}))(|(uid=%[1]s)(mail=%[1]s)))"
        admin-filter = "(memberof=cn=gitea_admin,{{ lldap_token.ldap_groups }})"
      }
      fields = [
        {
          fieldName = "bindPassword"
          length    = "32"
        }
      ]
    }
  }
}
data "kubernetes_secret_v1" "gitea_ldap_password" {
  depends_on = [kubernetes_manifest.gitea_ldap]
  metadata {
    name = "${var.component}-ldap"
    namespace = var.namespace
  }
}

resource "authentik_user" "gitea_ldapsearch" {
  username = "${var.component}-ldapsearch"
  name     = "${var.component}-ldapsearch"
}

resource "authentik_group" "gitea_ldapsearch" {
  name         = "${var.component}-ldapsearch"
  users        = [authentik_user.gitea_ldapsearch.id]
  is_superuser = true
}


data "http" "gitea_ldapsearch_password" {
  url    = "http://authentik.${var.domain}-auth.svc/api/v3/core/users/${authentik_user.gitea_ldapsearch.id}/set_password/"
  method = "POST"
  request_headers = {
    "Content-Type" = "application/json"
    Authorization  = "Bearer ${local.authentik-token}"
  }
  request_body = jsonencode({
    password=data.kubernetes_secret_v1.gitea_ldap_password.data["bindPassword"]
  })
  lifecycle {
    postcondition {
      condition     = contains([201, 204], self.status_code)
      error_message = "Status code invalid"
    }
  }
}

data "authentik_flow" "ldap-authentication-flow" {
  depends_on = [authentik_user.gitea_ldapsearch] # fake dependency so it is not evaluated at plan stage
  slug       = "ldap-authentication-flow"
}

resource "authentik_provider_ldap" "gitea_provider_ldap" {
  name         = "gitea-ldap-provider"
  base_dn      = local.base-dn
  search_group = authentik_group.gitea_ldapsearch.id
  bind_flow    = data.authentik_flow.ldap-authentication-flow.id
}

resource "authentik_application" "gitea_application" {
  name              = "gitea"
  slug              = "gitea"
  protocol_provider = authentik_provider_ldap.gitea_provider_ldap.id
  meta_launch_url   = format("https://%s.%s", var.sub-domain, var.domain-name)
  meta_icon         = format("https://%s.%s/%s", var.sub-domain, var.domain-name, "assets/img/logo.svg")
}

resource "authentik_group" "gitea_users" {
  name         = "gitea_users"
}

data "authentik_group" "vynil-admin" {
  depends_on = [authentik_group.gitea_users] # fake dependency so it is not evaluated at plan stage
  name = "vynil-admins"
}

resource "authentik_group" "gitea_admin" {
  name         = "gitea_admin"
  parent       = authentik_group.gitea_users.id
}

resource "authentik_policy_binding" "gitea_access_users" {
  target = authentik_application.gitea_application.uuid
  group  = authentik_group.gitea_users.id
  order  = 0
}
resource "authentik_policy_binding" "gitea_access_vynil" {
  target = authentik_application.gitea_application.uuid
  group  = data.authentik_group.vynil-admin.id
  order  = 1
}
resource "authentik_policy_binding" "gitea_access_ldap" {
  target = authentik_application.gitea_application.uuid
  group  = authentik_group.gitea_ldapsearch.id
  order  = 2
}

