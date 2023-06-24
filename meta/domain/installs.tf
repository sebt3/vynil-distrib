locals {
    global = {
        "domain"         = var.namespace
        "domain-name"    = var.domain-name
        "issuer"         = var.issuer
        "ingress-class"  = var.ingress-class
    }
    annotations = {
      "vynil.solidite.fr/meta" = "domain"
      "vynil.solidite.fr/name" = var.namespace
      "vynil.solidite.fr/domain" = var.domain-name
      "vynil.solidite.fr/issuer" = var.issuer
      "vynil.solidite.fr/ingress" = var.ingress-class
    }
    auth = { for k, v in var.auth : k => v if k!="enable" }
    infra = { for k, v in var.infra : k => v if k!="enable" }
    ci = { for k, v in var.ci : k => v if k!="enable" }

    # Force install authentik and it's modules when any are needed
    use-ldap = var.ci.gitea.enable
    use-forward = var.infra.traefik.enable
    use-other-auth = false
    added-auth-ldap = local.use-ldap?{
      "authentik-ldap" = {"enable"= true}
    }:{}
    added-auth-forward = local.use-forward?{
    }:{}
    added-auth = local.use-ldap||local.use-forward||local.use-other-auth?merge({
      "authentik" = {"enable" = true}
    },local.added-auth-ldap,local.added-auth-forward):{}
}

resource "kubectl_manifest" "auth" {
  count = var.auth.enable ? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "auth"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "meta"
      component: "domain-auth"
      options: ${jsonencode(merge(merge(local.global, local.auth), local.added-auth))}
  EOF
}
resource "kubectl_manifest" "infra" {
  count = var.infra.enable ? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "infra"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "meta"
      component: "domain-infra"
      options: ${jsonencode(merge(local.global, local.infra))}
  EOF
}
resource "kubectl_manifest" "ci" {
  count = var.ci.enable ? 1 : 0
  yaml_body  = <<-EOF
    apiVersion: "vynil.solidite.fr/v1"
    kind: "Install"
    metadata:
      name: "ci"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      distrib: "core"
      category: "meta"
      component: "domain-ci"
      options: ${jsonencode(merge(local.global, local.ci))}
  EOF
}
