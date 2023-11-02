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
        name: ndb-operator-app
      spec:
        template:
          spec:
            containers:
            - name: ndb-operator-controller
              image: "${var.image.registry}/${var.image.repository}:${var.image.tag}"
              imagePullPolicy: "${var.image.pullPolicy}"
              env:
              - name: NDB_OPERATOR_IMAGE
                value: "${var.image.registry}/${var.image.repository}:${var.image.tag}"
    EOF
  }
  patches {
    target {
      kind = "Deployment"
      name = "ndb-operator-webhook-server"
    }
    patch = <<-EOF
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: ndb-operator-webhook
      spec:
        template:
          spec:
            containers:
            - name: manager
              image: "${var.image.registry}/${var.image.repository}:${var.image.tag}"
              imagePullPolicy: "${var.image.pullPolicy}"
    EOF
  }
}

data "kustomization_overlay" "data_no_ns" {
  common_labels = local.common-labels
  resources = [for file in fileset(path.module, "*.yaml"): file if file != "index.yaml" && (length(regexall("ClusterRole",file))>0 || length(regexall("WebhookConfiguration",file))>0)]
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "ndb-operator-crb"
    }
    patch = <<-EOF
      apiVersion: rbac.authorization.k8s.io/v1
      kind: ClusterRoleBinding
      metadata:
        name: ndb-operator-crb
      subjects:
      - kind: ServiceAccount
        name: ndb-operator-app-sa
        namespace: "${var.namespace}"
    EOF
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "ndb-operator-webhook-crb"
    }
    patch = <<-EOF
      apiVersion: rbac.authorization.k8s.io/v1
      kind: ClusterRoleBinding
      metadata:
        name: ndb-operator-webhook-crb
      subjects:
      - kind: ServiceAccount
        name: ndb-operator-webhook-sa
        namespace: "${var.namespace}"
    EOF
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "vynil-dbo-ndb-operator-webhook-crb"
    }
    patch = <<-EOF
      apiVersion: rbac.authorization.k8s.io/v1
      kind: ClusterRoleBinding
      metadata:
        name: ndb-operator-crb
      subjects:
      - kind: ServiceAccount
        name: ndb-operator-webhook-sa
        namespace: "${var.namespace}"
    EOF
  }
  patches {
    target {
      kind = "MutatingWebhookConfiguration"
      name = "vynil-dbo-ndb-operator-mwc"
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
        name: mutating-webhook.ndbcluster.mysql.oracle.com
    EOF
  }
  patches {
    target {
      kind = "ValidatingWebhookConfiguration"
      name = "vynil-dbo-ndb-operator-vwc"
    }
    patch = <<-EOF
      apiVersion: admissionregistration.k8s.io/v1
      kind: ValidatingWebhookConfiguration
      metadata:
        name: vynil-dbo-ndb-operator-vwc
      webhooks:
      - clientConfig:
          service:
            namespace: ${var.namespace}
        name: validating-webhook.ndbcluster.mysql.oracle.com
    EOF
  }
}
