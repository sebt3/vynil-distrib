locals {
  request_headers = {
    "Content-Type"  = "application/json"
    Authorization   = "Bearer ${local.authentik-token}"
  }
  authentik-token = data.kubernetes_secret_v1.authentik.data["AUTHENTIK_BOOTSTRAP_TOKEN"]
  ldap-outpost-json = jsondecode(data.http.get_ldap_outpost.response_body).results
  ldap-outpost-prividers = length(local.ldap-outpost-json)>0?(contains(local.ldap-outpost-json[0].providers, authentik_provider_ldap.provider_ldap[0].id)?local.ldap-outpost-json[0].providers:concat(local.ldap-outpost-json[0].providers, [authentik_provider_ldap.provider_ldap[0].id])):[authentik_provider_ldap.provider_ldap[0].id]
}
//TODO: trouver un moyen d'attendre que le service soit ready
data "http" "get_ldap_outpost" {
  depends_on = [authentik_provider_ldap.provider_ldap]
  url    = "http://authentik.${var.namespace}.svc/api/v3/outposts/instances/?name__iexact=ldap"
  method = "GET"
  request_headers = local.request_headers
  lifecycle {
    postcondition {
      condition     = contains([200], self.status_code)
      error_message = "Status code invalid"
    }
  }
}

resource "authentik_stage_password" "ldap-password-stage" {
  depends_on = [data.kubernetes_secret_v1.authentik]
  name     = "ldap-authentication-password"
  backends = [
    "authentik.core.auth.InbuiltBackend",
    "authentik.core.auth.TokenBackend",
    "authentik.sources.ldap.auth.LDAPBackend"
  ]
}

resource "authentik_stage_identification" "ldap-identification-stage" {
  name           = "ldap-identification-stage"
  user_fields    = ["username","email"]
  password_stage = authentik_stage_password.ldap-password-stage.id
}

resource "authentik_stage_user_login" "ldap-authentication-login" {
  depends_on = [data.kubernetes_secret_v1.authentik]
  name = "ldap-authentication-login"
}

resource "authentik_flow" "ldap-authentication-flow" {
  depends_on = [data.kubernetes_secret_v1.authentik]
  name        = "ldap-authentication-flow"
  title       = "ldap authentication flow"
  slug        = "ldap-authentication-flow"
  designation = "authentication"
}

resource "authentik_flow_stage_binding" "ldap-authentication-flow-10" {
  target = authentik_flow.ldap-authentication-flow.uuid
  stage  = authentik_stage_identification.ldap-identification-stage.id
  order  = 10
}

resource "authentik_flow_stage_binding" "ldap-authentication-flow-30" {
  target = authentik_flow.ldap-authentication-flow.uuid
  stage  = authentik_stage_user_login.ldap-authentication-login.id
  order  = 30
}

data "authentik_user" "akadmin" {
  depends_on = [kustomization_resource.post,authentik_flow_stage_binding.ldap-authentication-flow-30]
  username = "akadmin"
}

resource "authentik_group" "group" {
  name         = "vynil-admins"
  users        = [data.authentik_user.akadmin.id]
  is_superuser = true
}

resource "authentik_service_connection_kubernetes" "local" {
  depends_on = [data.kubernetes_secret_v1.authentik]
  count = (var.outposts.ldap || var.outposts.forward) ? 1 : 0
  name  = "local"
  local = true
}

resource "authentik_provider_ldap" "provider_ldap" {
  count = var.outposts.ldap ? 1 : 0
  name         = "authentik-ldap-provider"
  base_dn      = "dc=${var.namespace},dc=namespace"
  bind_flow    = authentik_flow.ldap-authentication-flow.uuid
}

resource "authentik_outpost" "outpost-ldap" {
  count = var.outposts.ldap ? 1 : 0
  name = "ldap"
  type = "ldap"
  service_connection = authentik_service_connection_kubernetes.local[count.index].id
  config = jsonencode({
    "log_level": "info",
    "authentik_host": "http://authentik",
    "docker_map_ports": true,
    "kubernetes_replicas": 1,
    "kubernetes_namespace": var.namespace,
    "authentik_host_browser": "",
    "object_naming_template": "ak-outpost-%(name)s",
    "authentik_host_insecure": false,
    "kubernetes_service_type": "ClusterIP",
    "kubernetes_image_pull_secrets": [],
    "kubernetes_disabled_components": [],
    "kubernetes_ingress_annotations": {},
    "kubernetes_ingress_secret_name": "authentik-outpost-tls"
  })
  protocol_providers = local.ldap-outpost-prividers
}

data "authentik_flow" "default-authorization-flow" {
  depends_on = [kustomization_resource.post,authentik_flow_stage_binding.ldap-authentication-flow-30]
  slug = "default-provider-authorization-implicit-consent"
}

resource "authentik_provider_proxy" "provider_forward" {
  count = var.outposts.forward ? 1 : 0
  name               = "authentik-forward-provider"
  internal_host      = "http://authentik"
  external_host      = "http://authentik"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
}

resource "authentik_outpost" "outpost-forward" {
  count = var.outposts.forward ? 1 : 0
  name = "forward"
  type = "proxy"
  service_connection = authentik_service_connection_kubernetes.local[count.index].id
  config = jsonencode({
    "log_level": "info",
    "authentik_host": "http://authentik",
    "docker_map_ports": true,
    "kubernetes_replicas": 1,
    "kubernetes_namespace": var.namespace,
    "authentik_host_browser": "",
    "object_naming_template": "ak-outpost-%(name)s",
    "authentik_host_insecure": false,
    "kubernetes_service_type": "ClusterIP",
    "kubernetes_image_pull_secrets": [],
    "kubernetes_disabled_components": [],
    "kubernetes_ingress_annotations": {},
    "kubernetes_ingress_secret_name": "authentik-outpost-tls"
  })
  protocol_providers = [authentik_provider_proxy.provider_forward[count.index].id]
}

