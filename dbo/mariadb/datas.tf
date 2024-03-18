
data "kustomization_overlay" "data" {
  namespace = var.namespace
  resources = [ for file in fileset(path.module, "*.yaml"): file if file != "index.yaml"]

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
  patches {
    target {
      kind = "ServiceMonitor"
      name = "mariadb-operator-webhook"
    }
    patch = <<-EOF
      apiVersion: monitoring.coreos.com/v1
      kind: ServiceMonitor
      metadata:
        name: mariadb-operator-webhook
      spec:
        namespaceSelector:
          matchNames:
          - "${var.namespace}"
    EOF
  }
  patches {
    target {
      kind = "ServiceMonitor"
      name = "mariadb-operator"
    }
    patch = <<-EOF
      apiVersion: monitoring.coreos.com/v1
      kind: ServiceMonitor
      metadata:
        name: mariadb-operator
      spec:
        namespaceSelector:
          matchNames:
          - "${var.namespace}"
    EOF
  }
  patches {
    target {
      kind = "MutatingWebhookConfiguration"
      name = "mariadb-operator-webhook"
    }
    patch = <<-EOF
      apiVersion: admissionregistration.k8s.io/v1
      kind: MutatingWebhookConfiguration
      metadata:
        name: mariadb-operator-webhook
        annotations:
          cert-manager.io/inject-ca-from: ${var.namespace}/mariadb-operator-webhook-cert
      webhooks:
      - name: mmariadb.kb.io
        clientConfig:
          service:
            name: mariadb-operator-webhook
            namespace: "${var.namespace}"
    EOF
  }
  patches {
    target {
      kind = "ValidatingWebhookConfiguration"
      name = "mariadb-operator-webhook"
    }
    patch = <<-EOF
      apiVersion: admissionregistration.k8s.io/v1
      kind: ValidatingWebhookConfiguration
      metadata:
        name: mariadb-operator-webhook
        annotations:
          cert-manager.io/inject-ca-from: ${var.namespace}/mariadb-operator-webhook-cert
      webhooks:
      - name: vbackup.kb.io
        clientConfig:
          service:
            namespace: ${var.namespace}
      - name: vconnection.kb.io
        clientConfig:
          service:
            namespace: ${var.namespace}
      - name: vdatabase.kb.io
        clientConfig:
          service:
            namespace: ${var.namespace}
      - name: vgrant.kb.io
        clientConfig:
          service:
            namespace: ${var.namespace}
      - name: vmariadb.kb.io
        clientConfig:
          service:
            namespace: ${var.namespace}
      - name: vrestore.kb.io
        clientConfig:
          service:
            namespace: ${var.namespace}
      - name: vsqljob.kb.io
        clientConfig:
          service:
            namespace: ${var.namespace}
      - name: vuser.kb.io
        clientConfig:
          service:
            namespace: ${var.namespace}
    EOF
  }
}
