data "kubernetes_secret_v1" "authentik" {
  metadata {
    name = "authentik"
    namespace = "${var.domain}-auth"
  }
}
locals {
  base-dn = format("dc=%s", join(",dc=", split(".", format("%s.%s", var.sub-domain, var.domain-name))))
  base-group-dn = format("ou=groups,%s", local.base-dn)
  base-user-dn = format("ou=users,%s", local.base-dn)
  authentik-token = data.kubernetes_secret_v1.authentik.data["AUTHENTIK_BOOTSTRAP_TOKEN"]
  request_headers = {
    "Content-Type"  = "application/json"
    Authorization   = "Bearer ${local.authentik-token}"
  }
  ldap-outpost-providers = jsondecode(data.http.get_ldap_outpost.response_body).results[0].providers
  ldap-outpost-pk = jsondecode(data.http.get_ldap_outpost.response_body).results[0].pk
}

resource "kubectl_manifest" "dolibarr_ldap" {
  ignore_fields = ["metadata.annotations"]
  yaml_body  = <<-EOF
    apiVersion: "secretgenerator.mittwald.de/v1alpha1"
    kind: "StringSecret"
    metadata:
      name: "${var.instance}-${var.component}"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      forceRegenerate: false
      fields:
      - fieldName: "DOLI_LDAP_ADMIN_PASS"
        length: "32"
      - fieldName: "DOLI_ADMIN_PASSWORD"
        length: "32"
      - fieldName: "DOLI_COOKIE_CRYPTKEY"
        length: "32"
  EOF
}
data "kubernetes_secret_v1" "dolibarr_ldap_password" {
  depends_on = [kubectl_manifest.dolibarr_ldap]
  metadata {
    name = kubectl_manifest.dolibarr_ldap.name
    namespace = var.namespace
  }
}

resource "authentik_user" "dolibarr_ldapsearch" {
  username = "${var.instance}-${var.component}-ldapsearch"
  name     = "${var.instance}-${var.component}-ldapsearch"
}

resource "authentik_group" "dolibarr_ldapsearch" {
  name         = "${var.instance}-${var.component}-ldapsearch"
  users        = [authentik_user.dolibarr_ldapsearch.id]
  is_superuser = true
}


data "http" "dolibarr_ldapsearch_password" {
  url    = "http://authentik.${var.domain}-auth.svc/api/v3/core/users/${authentik_user.dolibarr_ldapsearch.id}/set_password/"
  method = "POST"
  request_headers = local.request_headers
  request_body = jsonencode({password=data.kubernetes_secret_v1.dolibarr_ldap_password.data["DOLI_LDAP_ADMIN_PASS"]})
  lifecycle {
    postcondition {
      condition     = contains([201, 204], self.status_code)
      error_message = "Status code invalid"
    }
  }
}


data "authentik_flow" "ldap-authentication-flow" {
  slug       = "ldap-authentication-flow"
}

resource "authentik_provider_ldap" "dolibarr_provider_ldap" {
  name         = "dolibarr-${var.instance}-ldap"
  base_dn      = local.base-dn
  search_group = authentik_group.dolibarr_ldapsearch.id
  bind_flow    = data.authentik_flow.ldap-authentication-flow.id
}

data "http" "get_ldap_outpost" {
  depends_on = [authentik_policy_binding.dolibarr_ldap_access_users] # fake dependency so it is not evaluated at plan stage
  url    = "http://authentik.${var.domain}-auth.svc/api/v3/outposts/instances/?name__iexact=ldap"
  method = "GET"
  request_headers = local.request_headers
  lifecycle {
    postcondition {
      condition     = contains([200], self.status_code)
      error_message = "Status code invalid"
    }
  }
}

provider "restapi" {
  uri = "http://authentik.${var.domain}-auth.svc/api/v3/"
  headers = local.request_headers
  create_method = "PATCH"
  update_method = "PATCH"
  destroy_method = "PATCH"
  write_returns_object = true
  id_attribute = "name"
}

resource "restapi_object" "ldap_outpost_binding" {
  path = "/outposts/instances/${local.ldap-outpost-pk}/"
  data = jsonencode({
    name = "ldap"
    providers = contains(local.ldap-outpost-providers, authentik_provider_ldap.dolibarr_provider_ldap.id) ? local.ldap-outpost-providers : concat(local.ldap-outpost-providers, [authentik_provider_ldap.dolibarr_provider_ldap.id])
  })
}

