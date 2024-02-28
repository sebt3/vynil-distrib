
locals {
  common-labels = {
    "vynil.solidite.fr/owner-name" = var.instance
    "vynil.solidite.fr/owner-namespace" = var.namespace
    "vynil.solidite.fr/owner-category" = var.category
    "vynil.solidite.fr/owner-component" = var.component
    "app.kubernetes.io/managed-by" = "vynil"
    "app.kubernetes.io/name" = "cloudnative-pg"
    "app.kubernetes.io/instance" = var.instance
  }
}
data "kustomization_overlay" "data" {
  common_labels = local.common-labels
  namespace = var.namespace
  resources = [for file in fileset(path.module, "*.yaml"): file if file != "index.yaml" && length(regexall("ClusterRole",file))<1 && length(regexall("WebhookConfiguration",file))<1]
  patches {
    target {
      kind = "Deployment"
      name = "cnpg-controller-manager"
    }
    patch = <<-EOF
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: cnpg-controller-manager
      spec:
        template:
          spec:
            containers:
            - name: manager
              image: "${var.image.registry}/${var.image.repository}:${var.image.tag}"
              imagePullPolicy: "${var.image.pullPolicy}"
              resources:
                limits:
                  cpu: "${var.resources.limits.cpu}"
                  memory: "${var.resources.limits.memory}"
                requests:
                  cpu: "${var.resources.requests.cpu}"
                  memory: "${var.resources.requests.memory}"
    EOF
  }
}

data "kustomization_overlay" "data_no_ns" {
  common_labels = local.common-labels
  resources = [for file in fileset(path.module, "*.yaml"): file if file != "index.yaml" && (length(regexall("ClusterRole",file))>0 || length(regexall("WebhookConfiguration",file))>0)]
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "cnpg-manager-rolebinding"
    }
    patch = <<-EOF
      apiVersion: rbac.authorization.k8s.io/v1
      kind: ClusterRoleBinding
      metadata:
        name: cnpg-manager-rolebinding
      subjects:
      - kind: ServiceAccount
        name: cnpg-manager
        namespace: "${var.namespace}"
    EOF
  }
  patches {
    target {
      kind = "MutatingWebhookConfiguration"
      name = "cnpg-mutating-webhook-configuration"
    }
    patch = <<-EOF
      apiVersion: admissionregistration.k8s.io/v1
      kind: MutatingWebhookConfiguration
      metadata:
        name: cnpg-mutating-webhook-configuration
      webhooks:
      - clientConfig:
          service:
            namespace: ${var.namespace}
        name: mbackup.cnpg.io
      - clientConfig:
          service:
            namespace: ${var.namespace}
        name: mcluster.cnpg.io
      - clientConfig:
          service:
            namespace: ${var.namespace}
        name: mscheduledbackup.cnpg.io
    EOF
  }
  patches {
    target {
      kind = "ValidatingWebhookConfiguration"
      name = "cnpg-validating-webhook-configuration"
    }
    patch = <<-EOF
      apiVersion: admissionregistration.k8s.io/v1
      kind: ValidatingWebhookConfiguration
      metadata:
        name: cnpg-validating-webhook-configuration
      webhooks:
      - clientConfig:
          service:
            namespace: ${var.namespace}
        name: vbackup.cnpg.io
      - clientConfig:
          service:
            namespace: ${var.namespace}
        name: vcluster.cnpg.io
      - clientConfig:
          service:
            namespace: ${var.namespace}
        name: vpooler.cnpg.io
      - clientConfig:
          service:
            namespace: ${var.namespace}
        name: vscheduledbackup.cnpg.io
    EOF
  }
}
