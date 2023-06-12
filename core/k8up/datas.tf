
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
  resources = [for file in fileset(path.module, "*.yaml"): file if file != "index.yaml" && length(regexall("ClusterRole",file))<1]
  images {
    name = "ghcr.io/k8up-io/k8up"
    new_name = "${var.images.operator.registry}/${var.images.operator.repository}"
    new_tag = "${var.images.operator.tag}"
  }
  patches {
    target {
      kind = "Deployment"
      name = "k8up"
      namespace = "k8up"
    }
    patch = <<-EOF
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: k8up
        namespace: "${var.namespace}"
      spec:
        template:
          spec:
            containers:
            - name: k8up-operator
              env:
              - name: BACKUP_IMAGE
                value: "${var.images.backup.registry}/${var.images.backup.repository}:${var.images.backup.tag}"
              - name: TZ
                value: "${var.timezone}"
              imagePullPolicy: "${var.images.operator.pullPolicy}"
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
  resources = [for file in fileset(path.module, "*.yaml"): file if file != "index.yaml" && length(regexall("ClusterRole",file))>0]
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "k8up"
    }
    patch = <<-EOF
      apiVersion: rbac.authorization.k8s.io/v1
      kind: ClusterRoleBinding
      metadata:
        name: k8up
      subjects:
      - kind: ServiceAccount
        name: k8up
        namespace: "${var.namespace}"
    EOF
  }
}
