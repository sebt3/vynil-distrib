resource "kubectl_manifest" "selfsigned-issuer" {
  yaml_body  = <<-EOF
    apiVersion: "cert-manager.io/v1"
    kind: "ClusterIssuer"
    metadata:
      name: "letsencrypt-prod"
      labels: ${jsonencode(local.common-labels)}
    spec:
      acme:
        # The ACME server URL
        server: "https://acme-v02.api.letsencrypt.org/directory"
        # Email address used for ACME registration
        email: "${var.mail}"
        # Name of a secret used to store the ACME account private key
        privateKeySecretRef:
          name: "letsencrypt-prod-secret"
        # Enable the HTTP-01 challenge provider
        solvers:
        - http01:
            ingress:
              class: "${var.ingress-class}"
  EOF
}
