data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}
data "authentik_flow" "default-authentication-flow" {
  slug = "default-authentication-flow"
}

data "authentik_property_mapping_saml" "saml_maps" {
  managed_list = [
      "goauthentik.io/providers/saml/email",
      "goauthentik.io/providers/saml/groups",
      "goauthentik.io/providers/saml/name",
      "goauthentik.io/providers/saml/upn",
      "goauthentik.io/providers/saml/uid",
      "goauthentik.io/providers/saml/username",
      "goauthentik.io/providers/saml/ms-windowsaccountname",
  ]
}

data "authentik_property_mapping_saml" "saml_name" {
  managed = "goauthentik.io/providers/saml/username"
}

data "authentik_certificate_key_pair" "generated" {
  name = "authentik Self-signed Certificate"
}

resource "authentik_provider_saml" "dolibarr" {
  name                = "dolibarr-${var.instance}-saml"
  authentication_flow = data.authentik_flow.default-authentication-flow.id
  authorization_flow  = data.authentik_flow.default-authorization-flow.id
  acs_url             = "https://${var.sub-domain}.${var.domain-name}/custom/samlconnector/acs.php?entity=1&fk_idp=0"
  property_mappings   = data.authentik_property_mapping_saml.saml_maps.ids
  name_id_mapping     = data.authentik_property_mapping_saml.saml_name.id
  signing_kp          = data.authentik_certificate_key_pair.generated.id
  sp_binding          = "post"
}
