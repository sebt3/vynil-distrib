
data "kustomization_overlay" "data" {
  namespace = var.namespace
  resources = concat([
    "https://raw.githubusercontent.com/mariadb-operator/mariadb-operator/v0.0.11/deploy/crds/crds.yaml"
  ],[ for file in fileset(path.module, "*.yaml"): file if file != "index.yaml"])

  patches {
    target {
      kind = "Certificate"
      name = "mariadb-operator-webhook-cert"
    }
    patch = <<-EOF
      apiVersion: cert-manager.io/v1
      kind: Certificate
      metadata:
        name: mariadb-operator-webhook-cert
      spec:
        dnsNames:
        - mariadb-operator-webhook.${var.namespace}.svc
        - mariadb-operator-webhook.${var.namespace}.svc.cluster.local
    EOF
  }
}
