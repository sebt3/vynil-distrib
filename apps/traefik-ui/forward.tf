locals {
  authentik-token = data.kubernetes_secret_v1.authentik.data["AUTHENTIK_BOOTSTRAP_TOKEN"]
  request_headers = {
    "Content-Type"  = "application/json"
    Authorization   = "Bearer ${local.authentik-token}"
  }
  forward-outpost-providers = jsondecode(data.http.get_forward_outpost.response_body).results[0].providers
  forward-outpost-pk = jsondecode(data.http.get_forward_outpost.response_body).results[0].pk
  app-name = var.component == var.instance ? var.instance : format("%s-%s", var.component, var.instance)
  app-icon = "dashboard/statics/icons/favicon-96x96.png"
  main-group = format("%s-users", local.app-name)
  sub-groups = []
  internal-url = "http://${var.instance}.${var.namespace}.svc:9000"
}


data "authentik_flow" "default-authorization-flow" {
  depends_on = [authentik_group.prj_users]
  slug = "default-provider-authorization-implicit-consent"
}

resource "authentik_provider_proxy" "prj_forward" {
  name               = local.app-name
  internal_host      = local.internal-url
  external_host      = format("https://%s.%s", var.sub-domain, var.domain-name)
  authorization_flow = data.authentik_flow.default-authorization-flow.id
}


resource "authentik_application" "prj_application" {
  name              = local.app-name
  slug              = local.app-name
  protocol_provider = authentik_provider_proxy.prj_forward.id
  meta_launch_url   = format("https://%s.%s", var.sub-domain, var.domain-name)
  meta_icon         = format("https://%s.%s/%s", var.sub-domain, var.domain-name, local.app-icon)
}

resource "authentik_group" "prj_users" {
  name         = local.main-group
}

resource "authentik_group" "subgroup" {
  count = length(local.sub-groups)
  name         = format("%s-%s", local.app-name, local.sub-groups[count.index])
  parent       = authentik_group.prj_users.id
}

data "authentik_group" "vynil-admin" {
  depends_on = [authentik_group.prj_users] # fake dependency so it is not evaluated at plan stage
  name = "vynil-forward-admins"
}

resource "authentik_policy_binding" "prj_access_users" {
  target = authentik_application.prj_application.uuid
  group  = authentik_group.prj_users.id
  order  = 0
}
resource "authentik_policy_binding" "prj_access_vynil" {
  target = authentik_application.prj_application.uuid
  group  = data.authentik_group.vynil-admin.id
  order  = 1
}

data "http" "get_forward_outpost" {
  depends_on = [authentik_provider_proxy.prj_forward]
  url    = "http://authentik.${var.domain}-auth.svc/api/v3/outposts/instances/?name__iexact=forward"
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

resource "restapi_object" "forward_outpost_binding" {
  path = "/outposts/instances/${local.forward-outpost-pk}/"
  data = jsonencode({
    name = "forward"
    providers = contains(local.forward-outpost-providers, authentik_provider_proxy.prj_forward.id) ? local.forward-outpost-providers : concat(local.forward-outpost-providers, [authentik_provider_proxy.prj_forward.id])
  })
}

resource "kubectl_manifest" "prj_middleware" {
  yaml_body  = <<-EOF
    apiVersion: traefik.containo.us/v1alpha1
    kind: Middleware
    metadata:
        name: "forward-${local.app-name}"
        namespace: "${var.namespace}"
        labels: ${jsonencode(local.common-labels)}
    spec:
      forwardAuth:
        address: http://ak-outpost-forward.${var.domain}-auth.svc:9000/outpost.goauthentik.io/auth/traefik
        trustForwardHeader: true
        authResponseHeaders:
          - X-authentik-username
        #   - X-authentik-groups
        #   - X-authentik-email
        #   - X-authentik-name
        #   - X-authentik-uid
        #   - X-authentik-jwt
        #   - X-authentik-meta-jwks
        #   - X-authentik-meta-outpost
        #   - X-authentik-meta-provider
        #   - X-authentik-meta-app
        #   - X-authentik-meta-version
  EOF
}
