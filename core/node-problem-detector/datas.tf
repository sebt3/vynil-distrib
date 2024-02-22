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
  namespace = var.namespace
  common_labels = local.common-labels
  resources = [for file in fileset(path.module, "*.yaml"): file if file != "index.yaml" && length(regexall("ClusterRole",file))<1 ]
  images {
    name = "registry.k8s.io/node-problem-detector/node-problem-detector"
    new_name = "${var.images.node-problem-detector.registry}/${var.images.node-problem-detector.repository}"
    new_tag = "${var.images.node-problem-detector.tag}"
  }
  patches {
    target {
      kind = "DaemonSet"
      name = "npd-node-problem-detector"
    }
    patch = <<-EOF
      apiVersion: apps/v1
      kind: DaemonSet
      metadata:
        name: npd-node-problem-detector
      spec:
        template:
          spec:
            containers:
            - name: node-problem-detector
              imagePullPolicy: "${var.images.node-problem-detector.pull_policy}"
    EOF
  }
}

data "kustomization_overlay" "data_no_ns" {
  common_labels = local.common-labels
  resources = [for file in fileset(path.module, "*.yaml"): file if file != "index.yaml" && length(regexall("ClusterRole",file))>0 ]
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "npd-node-problem-detector"
    }
    patch = local.rb-patch
  }
}
