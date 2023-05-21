
data "kustomization_overlay" "data" {
  namespace = var.namespace
  resources = [ for file in fileset(path.module, "*.yaml"): file if file != "index.yaml"]
  patches {
    target {
      kind = "ClusterIssuer"
      name = "letsencrypt-prod"
    }
    patch = <<-EOF
      apiVersion: cert-manager.io/v1
      kind: ClusterIssuer
      metadata:
        name: letsencrypt-prod
      spec:
        acme:
          email: "${var.mail}"
    EOF
  }
}
