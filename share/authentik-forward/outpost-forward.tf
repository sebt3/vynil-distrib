locals {
  request_headers = {
    "Content-Type"  = "application/json"
    Authorization   = "Bearer ${local.authentik-token}"
  }
  authentik-token = data.kubernetes_secret_v1.authentik.data["AUTHENTIK_BOOTSTRAP_TOKEN"]
  forward-outpost-json = jsondecode(data.http.get_forward_outpost.response_body).results
  forward-outpost-providers = length(local.forward-outpost-json)>0?(contains(local.forward-outpost-json[0].providers, authentik_provider_proxy.provider_forward.id)?local.forward-outpost-json[0].providers:concat(local.forward-outpost-json[0].providers, [authentik_provider_proxy.provider_forward.id])):[authentik_provider_proxy.provider_forward.id]
}

data "http" "get_forward_outpost" {
  depends_on = [authentik_provider_proxy.provider_forward]
  url    = "http://authentik.${var.namespace}.svc/api/v3/outposts/instances/?name__iexact=forward"
  method = "GET"
  request_headers = local.request_headers
  lifecycle {
    postcondition {
      condition     = contains([200], self.status_code)
      error_message = "Status code invalid"
    }
  }
}

resource "authentik_service_connection_kubernetes" "local" {
  depends_on = [data.kubernetes_secret_v1.authentik]
  name  = "local-forward"
  local = true
}

data "authentik_flow" "default-authorization-flow" {
  depends_on = [authentik_service_connection_kubernetes.local]
  slug = "default-provider-authorization-implicit-consent"
}

resource "authentik_provider_proxy" "provider_forward" {
  name               = "authentik-forward-provider"
  internal_host      = "http://authentik"
  external_host      = "http://authentik"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
}

resource "authentik_outpost" "outpost-forward" {
  name = "forward"
  type = "proxy"
  service_connection = authentik_service_connection_kubernetes.local.id
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
  protocol_providers = local.forward-outpost-providers
}

data "authentik_user" "akadmin" {
  depends_on = [authentik_outpost.outpost-forward]
  username = "akadmin"
}

resource "authentik_group" "group" {
  name         = "vynil-forward-admins"
  users        = [data.authentik_user.akadmin.id]
  is_superuser = true
}
