
locals {
  common-labels = {
    "vynil.solidite.fr/owner-name" = var.instance
    "vynil.solidite.fr/owner-namespace" = var.namespace
    "vynil.solidite.fr/owner-category" = var.category
    "vynil.solidite.fr/owner-component" = var.component
    "app.kubernetes.io/managed-by" = "vynil"
    "app.kubernetes.io/name" = var.component
    "app.kubernetes.io/instance" = var.instance
  }
  rb-patch = <<-EOF
    - op: replace
      path: /subjects/0/namespace
      value: "${var.namespace}"
    EOF
}
data "kustomization_overlay" "data" {
  common_labels = local.common-labels
  namespace = var.namespace
  resources = [for file in fileset(path.module, "*.yaml"): file if file != "index.yaml" && length(regexall("ClusterRole",file))<1 && length(regexall("WebhookConfiguration",file))<1]
  images {
    name = "ghcr.io/open-telemetry/opentelemetry-operator/opentelemetry-operator"
    new_name = "${var.images.operator.registry}/${var.images.operator.repository}"
    new_tag = "${var.images.operator.tag}"
  }
  images {
    name = "quay.io/brancz/kube-rbac-proxy"
    new_name = "${var.images.rbac_proxy.registry}/${var.images.rbac_proxy.repository}"
    new_tag = "${var.images.rbac_proxy.tag}"
  }
  patches {
    target {
      kind = "Certificate"
      name = "open-telemetry-opentelemetry-operator-serving-cert"
    }
    patch = <<-EOF
    - op: replace
      path: /spec/dnsNames/0
      value: "open-telemetry-opentelemetry-operator-webhook.${var.namespace}.svc"
    - op: replace
      path: /spec/dnsNames/1
      value: "open-telemetry-opentelemetry-operator-webhook.${var.namespace}.svc.cluster.local"
    EOF
  }
  patches {
    target {
      kind = "Deployment"
      name = "open-telemetry-opentelemetry-operator"
    }
    patch = <<-EOF
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: open-telemetry-opentelemetry-operator
      spec:
        replicas: ${var.replicas}
    EOF
  }
}

data "kustomization_overlay" "data_no_ns" {
  common_labels = local.common-labels
  resources = [for file in fileset(path.module, "*.yaml"): file if file != "index.yaml" && (length(regexall("ClusterRole",file))>0 || length(regexall("WebhookConfiguration",file))>0)]
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "open-telemetry-opentelemetry-operator-manager"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "open-telemetry-opentelemetry-operator-proxy"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "MutatingWebhookConfiguration"
      name = "open-telemetry-opentelemetry-operator-mutation"
    }
    patch = <<-EOF
    - op: replace
      path: /webhooks/0/clientConfig/service/namespace
      value: "${var.namespace}"
    - op: replace
      path: /webhooks/1/clientConfig/service/namespace
      value: "${var.namespace}"
    - op: replace
      path: /webhooks/2/clientConfig/service/namespace
      value: "${var.namespace}"
    - op: replace
      path: /metadata/annotations/certmanager.k8s.io~1inject-ca-from
      value: "${var.namespace}/open-telemetry-opentelemetry-operator-serving-cert"
    EOF
  }
  patches {
    target {
      kind = "ValidatingWebhookConfiguration"
      name = "open-telemetry-opentelemetry-operator-validation"
    }
    patch = <<-EOF
    - op: replace
      path: /webhooks/0/clientConfig/service/namespace
      value: "${var.namespace}"
    - op: replace
      path: /webhooks/1/clientConfig/service/namespace
      value: "${var.namespace}"
    - op: replace
      path: /webhooks/2/clientConfig/service/namespace
      value: "${var.namespace}"
    - op: replace
      path: /webhooks/3/clientConfig/service/namespace
      value: "${var.namespace}"
    - op: replace
      path: /metadata/annotations/certmanager.k8s.io~1inject-ca-from
      value: "${var.namespace}/open-telemetry-opentelemetry-operator-serving-cert"
    EOF
  }
}
