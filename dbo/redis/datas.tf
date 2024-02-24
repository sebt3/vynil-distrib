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
  resources = [ for file in fileset(path.module, "*.yaml"): file if file != "index.yaml"]
  patches {
    target {
      kind = "Deployment"
      name = "redis-operator"
    }
    patch = <<-EOF
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: redis-operator
        namespace: dbo-redis
      spec:
        template:
          spec:
            containers:
            - name: "redis-operator"
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
      name = "redis-operator-certmanager-cainjector"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "redis-operator-certmanager-controller-approve:cert-manager-io"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "redis-operator-certmanager-controller-certificates"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "redis-operator-certmanager-controller-certificatesigningrequests"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "redis-operator-certmanager-controller-challenges"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "redis-operator-certmanager-controller-clusterissuers"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "redis-operator-certmanager-controller-ingress-shim"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "redis-operator-certmanager-controller-issuers"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "redis-operator-certmanager-controller-orders"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "redis-operator-certmanager-webhook:subjectaccessreviews"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "ClusterRoleBinding"
      name = "redis-operator"
    }
    patch = local.rb-patch
  }
  patches {
    target {
      kind = "MutatingWebhookConfiguration"
      name = "prometheus-community-kube-admission"
    }
    patch = <<-EOF
    - op: replace
      path: /webhooks/0/clientConfig/service/namespace
      value: "${var.namespace}"
    - op: replace
      path: /metadata/annotations/certmanager.k8s.io~1inject-ca-from
      value: "${var.namespace}/prometheus-community-kube-admission"
    - op: replace
      path: /metadata/annotations/cert-manager.io~1inject-ca-from
      value: "${var.namespace}/prometheus-community-kube-admission"
    EOF
  }
  patches {
    target {
      kind = "ValidatingWebhookConfiguration"
      name = "prometheus-community-kube-admission"
    }
    patch = <<-EOF
    - op: replace
      path: /webhooks/0/clientConfig/service/namespace
      value: "${var.namespace}"
    - op: replace
      path: /metadata/annotations/certmanager.k8s.io~1inject-ca-from
      value: "${var.namespace}/prometheus-community-kube-admission"
    - op: replace
      path: /metadata/annotations/cert-manager.io~1inject-ca-from
      value: "${var.namespace}/prometheus-community-kube-admission"
    EOF
  }
}


