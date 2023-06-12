resource "authentik_stage_password" "ldap-password-stage" {
  depends_on = [kustomization_resource.post]
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
  depends_on = [kustomization_resource.post]
  name = "ldap-authentication-login"
}

resource "authentik_flow" "ldap-authentication-flow" {
  depends_on = [kustomization_resource.post]
  name        = "ldap-authentication-flow"
  title       = "ldap authentication flow"
  slug        = "ldap-authentication-flow"
  designation = "authorization"
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
  name  = "local"
  local = true
}

resource "authentik_outpost" "outpost-ldap" {
  count = var.outposts.ldap ? 1 : 0
  name = "ldap"
  type = "ldap"
  service_connection = authentik_service_connection_kubernetes.local.id
  config = jsonencode({
    "log_level": "info",
    "authentik_host": "authentik",
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
  protocol_providers = []
}

resource "authentik_outpost" "outpost-forward" {
  count = var.outposts.forward ? 1 : 0
  name = "forward"
  type = "proxy"
  service_connection = authentik_service_connection_kubernetes.local.id
  config = jsonencode({
    "log_level": "info",
    "authentik_host": "authentik",
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
  protocol_providers = []
}

