
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
    name = "gcr.io/tekton-releases/github.com/tektoncd/triggers/cmd/controller"
    new_name = "${var.images.controller.registry}/${var.images.controller.repository}"
    new_tag = "${var.images.controller.tag}"
  }
  images {
    name = "gcr.io/tekton-releases/github.com/tektoncd/triggers/cmd/interceptors"
    new_name = "${var.images.interceptors.registry}/${var.images.interceptors.repository}"
    new_tag = "${var.images.interceptors.tag}"
  }
  images {
    name = "gcr.io/tekton-releases/github.com/tektoncd/triggers/cmd/webhook"
    new_name = "${var.images.webhook.registry}/${var.images.webhook.repository}"
    new_tag = "${var.images.webhook.tag}"
  }
  patches {
    target {
      kind = "Deployment"
      name = "tekton-triggers-webhook"
    }
    patch = <<-EOF
    - op: replace
      path: /spec/template/spec/containers/0/imagePullPolicy
      value: "${var.images.webhook.pull_policy}"
    EOF
  }
  patches {
    target {
      kind = "Deployment"
      name = "tekton-triggers-core-interceptors"
    }
    patch = <<-EOF
    - op: replace
      path: /spec/template/spec/containers/0/imagePullPolicy
      value: "${var.images.interceptors.pull_policy}"
    EOF
  }
  patches {
    target {
      kind = "Deployment"
      name = "tekton-triggers-controller"
    }
    patch = <<-EOF
    - op: replace
      path: /spec/template/spec/containers/0/imagePullPolicy
      value: "${var.images.controller.pull_policy}"
    EOF
  }
}

data "kustomization_overlay" "data_no_ns" {
  common_labels = local.common-labels
  resources = [for file in fileset(path.module, "*.yaml"): file if file != "index.yaml" && (length(regexall("ClusterRole",file))>0 || length(regexall("WebhookConfiguration",file))>0)]
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "tekton-triggers-controller-admin"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "tekton-triggers-core-interceptors-secrets"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "tekton-triggers-core-interceptors"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "tekton-triggers-webhook-admin"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "MutatingWebhookConfiguration"
      name = "webhook.triggers.tekton.dev"
    }
    patch = <<-EOF
    - op: replace
      path: /webhooks/0/clientConfig/service/namespace
      value: "${var.namespace}"
    EOF
  }
  patches {
    target {
      kind = "ValidatingWebhookConfiguration"
      name = "config.webhook.triggers.tekton.dev"
    }
    patch = <<-EOF
    - op: replace
      path: /webhooks/0/clientConfig/service/namespace
      value: "${var.namespace}"
    EOF
  }
  patches {
    target {
      kind = "ValidatingWebhookConfiguration"
      name = "validation.webhook.triggers.tekton.dev"
    }
    patch = <<-EOF
    - op: replace
      path: /webhooks/0/clientConfig/service/namespace
      value: "${var.namespace}"
    EOF
  }
}


