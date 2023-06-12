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

resource "authentik_user" "akadmin" {
  depends_on = [kustomization_resource.post]
  username = "akadmin"
}

resource "authentik_group" "group" {
  depends_on = [kustomization_resource.post]
  name         = "vynil-admins"
  users        = [authentik_user.akadmin.id]
  is_superuser = true
}
