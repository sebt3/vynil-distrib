locals {
  sorted-group-names = reverse(distinct(sort([
    for grp in var.user-groups: grp.name
  ])))
  sorted-groups = compact(flatten([
    for name in local.sorted-group-names: [
      for grp in var.user-groups:
        grp if grp.name == name
    ]
  ]))
}

data "authentik_group" "vynil-admin" {
  name = "vynil-ldap-admins"
}

resource "authentik_group" "groups" {
  count = length(local.sorted-groups)
  name         = local.sorted-groups[count.index].name
}

resource "authentik_application" "dolibarr_application_ldap" {
  name              = "${var.component}-${var.instance}-ldap"
  slug              = "${var.component}-${var.instance}-ldap"
  protocol_provider = authentik_provider_ldap.dolibarr_provider_ldap.id
  meta_launch_url   = "blank://blank"
}

resource "authentik_policy_binding" "dolibarr_ldap_access_users" {
  count = length(local.sorted-groups)
  target = authentik_application.dolibarr_application_ldap.uuid
  group  = authentik_group.groups[count.index].id
  order  = count.index
}
resource "authentik_policy_binding" "dolibarr_ldap_access_ldap" {
  target = authentik_application.dolibarr_application_ldap.uuid
  group  = authentik_group.dolibarr_ldapsearch.id
  order  = length(local.sorted-groups)+1
}
resource "authentik_policy_binding" "dolibarr_ldap_access_vynil" {
  target = authentik_application.dolibarr_application_ldap.uuid
  group  = data.authentik_group.vynil-admin.id
  order  = length(local.sorted-groups)+2
}

resource "authentik_application" "dolibarr_application_saml" {
  name              = var.component==var.instance?var.component:"${var.component}-${var.instance}"
  slug              = "${var.component}-${var.instance}"
  protocol_provider = authentik_provider_saml.dolibarr.id
  meta_launch_url   = format("https://%s.%s", var.sub-domain, var.domain-name)
  meta_icon         = format("https://%s.%s/%s", var.sub-domain, var.domain-name, "theme/dolibarr_256x256_color.png")
}

resource "authentik_policy_binding" "dolibarr_saml_access_users" {
  count = length(local.sorted-groups)
  target = authentik_application.dolibarr_application_saml.uuid
  group  = authentik_group.groups[count.index].id
  order  = count.index
}
resource "authentik_policy_binding" "dolibarr_saml_access_vynil" {
  target = authentik_application.dolibarr_application_saml.uuid
  group  = data.authentik_group.vynil-admin.id
  order  = length(local.sorted-groups)+1
}
