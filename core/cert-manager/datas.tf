
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
  resources = [for file in fileset(path.module, "*.yaml"): file if file != "index.yaml" && length(regexall("leaderelection.yaml",file))<1 && length(regexall("ClusterRole",file))<1 && length(regexall("WebhookConfiguration",file))<1]
  images {
    name = "quay.io/jetstack/cert-manager-cainjector"
    new_name = "${var.images.cainjector.registry}/${var.images.cainjector.repository}"
    new_tag = "${var.images.cainjector.tag}"
  }
  images {
    name = "quay.io/jetstack/cert-manager-controller"
    new_name = "${var.images.controller.registry}/${var.images.controller.repository}"
    new_tag = "${var.images.controller.tag}"
  }
  images {
    name = "quay.io/jetstack/cert-manager-webhook"
    new_name = "${var.images.webhook.registry}/${var.images.webhook.repository}"
    new_tag = "${var.images.webhook.tag}"
  }
  images {
    name = "quay.io/jetstack/cert-manager-ctl"
    new_name = "${var.images.startupapicheck.registry}/${var.images.startupapicheck.repository}"
    new_tag = "${var.images.startupapicheck.tag}"
  }
}

data "kustomization_overlay" "data_no_ns" {
  common_labels = local.common-labels
  resources = [for file in fileset(path.module, "*.yaml"): file if file != "index.yaml" && (length(regexall("leaderelection.yaml",file))>0 || length(regexall("ClusterRole",file))>0 || length(regexall("WebhookConfiguration",file))>0)]
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "cert-manager-cainjector"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "cert-manager-controller-approve:cert-manager-io"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "cert-manager-controller-certificates"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "cert-manager-controller-certificatesigningrequests"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "cert-manager-controller-challenges"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "cert-manager-controller-clusterissuers"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "cert-manager-controller-ingress-shim"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "cert-manager-controller-issuers"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "cert-manager-controller-orders"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "cert-manager-webhook:subjectaccessreviews"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "RoleBinding"
      name = "cert-manager-cainjector:leaderelection"
      namespace = "kube-system"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "RoleBinding"
      name = "cert-manager:leaderelection"
      namespace = "kube-system"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "MutatingWebhookConfiguration"
      name = "cert-manager-webhook"
    }
    patch = <<-EOF
    - op: replace
      path: /webhooks/0/clientConfig/service/namespace
      value: "${var.namespace}"
    - op: replace
      path: /metadata/annotations/cert-manager.io~1inject-ca-from-secret
      value: "${var.namespace}/cert-manager-webhook-ca"
    EOF
  }
  patches {
    target {
      kind = "ValidatingWebhookConfiguration"
      name = "cert-manager-webhook"
    }
    patch = <<-EOF
    - op: replace
      path: /webhooks/0/clientConfig/service/namespace
      value: "${var.namespace}"
    - op: replace
      path: /metadata/annotations/cert-manager.io~1inject-ca-from-secret
      value: "${var.namespace}/cert-manager-webhook-ca"
    EOF
  }
}
