data "kustomization_overlay" "data" {
  namespace = var.namespace
  resources = [ for file in fileset(path.module, "*.yaml"): file if file != "index.yaml"]
  patches {
    target {
      kind = "ClusterIssuer"
      name = "ca-issuer"
    }
    patch = <<-EOF
      apiVersion: cert-manager.io/v1
      kind: ClusterIssuer
      metadata:
        name: ca-issuer
      spec:
        ca:
          namespace: "${var.namespace}"
    EOF
  }
  patches {
    target {
      kind = "Certificate"
      name = "selfsigned-ca"
    }
    patch = <<-EOF
      apiVersion: cert-manager.io/v1
      kind: Certificate
      metadata:
        name: selfsigned-ca
      spec:
        commonName: "${var.commonName}"
    EOF
  }
}
