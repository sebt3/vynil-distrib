resource "kubectl_manifest" "selfsigned-issuer" {
  yaml_body  = <<-EOF
    apiVersion: "cert-manager.io/v1"
    kind: "ClusterIssuer"
    metadata:
      name: "selfsigned-issuer"
      labels: ${jsonencode(local.common-labels)}
    spec:
      selfSigned: {}
  EOF
}

resource "kubectl_manifest" "selfsigned-ca" {
  yaml_body  = <<-EOF
    apiVersion: "cert-manager.io/v1"
    kind: "Certificate"
    metadata:
      name: "selfsigned-ca"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      isCA: true
      duration: "${var.duration}"
      commonName: "${var.commonName}"
      secretName: "selfsigned-ca"
      privateKey:
        algorithm: "ECDSA"
        size: 256
      issuerRef:
        name: "selfsigned-issuer"
        kind: "ClusterIssuer"
        group: "cert-manager.io"
  EOF
}

resource "kubectl_manifest" "ca-issuer" {
  yaml_body  = <<-EOF
    apiVersion: "cert-manager.io/v1"
    kind: "ClusterIssuer"
    metadata:
      name: "self-sign"
      labels: ${jsonencode(local.common-labels)}
    spec:
      ca:
        secretName: "selfsigned-ca"
  EOF
}

