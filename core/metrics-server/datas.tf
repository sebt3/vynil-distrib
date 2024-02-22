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
  resources = [for file in fileset(path.module, "*.yaml"): file if file != "index.yaml" && length(regexall("APIService",file))<1 && length(regexall("Role",file))<1 ]
}

data "kustomization_overlay" "data_no_ns" {
  common_labels = local.common-labels
  resources = [for file in fileset(path.module, "*.yaml"): file if file != "index.yaml" && (length(regexall("APIService",file))>0 || length(regexall("Role",file))>0) ]
  patches {
    target {
      kind = "RoleBinding"
      name = "metrics-server-auth-reader"
      namespace = "kube-system"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "metrics-server:system:auth-delegator"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "system:metrics-server"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "APIService"
      name = "v1beta1.metrics.k8s.io"
    }
    patch = <<-EOF
      apiVersion: apiregistration.k8s.io/v1
      kind: APIService
      metadata:
        name: v1beta1.metrics.k8s.io
      spec:
        service:
          name: metrics-server
          namespace: "${var.namespace}"
    EOF
  }
}
