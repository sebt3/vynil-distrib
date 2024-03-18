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
  namespace = var.namespace
  common_labels = local.common-labels
  resources = [ for file in fileset(path.module, "*.yaml"): file if file != "index.yaml"]
  patches {
    target {
      kind = "DaemonSet"
      name = "traefik"
    }
    patch = <<-EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: traefik
spec:
  template:
    spec:
      containers:
      - name: traefik
        image: "${var.image.registry}/${var.image.repository}:${var.image.tag}"
        imagePullPolicy: "${var.image.pullPolicy}"
    EOF
  }
  patches {
    target {
      kind = "DaemonSet"
      name = "traefik"
    }
    patch = <<-EOF
      - op: add
        path: /spec/template/spec/containers/0/args/-
        value: "--providers.kubernetesingress.ingressclass=${var.ingressClass}"
    EOF
  }
  patches {
    target {
      kind = "IngressClass"
      name = "traefik"
    }
    patch = <<-EOF
      - op: replace
        path: /metadata/name
        value: "${var.ingressClass}"
      - op: replace
        path: "/metadata/annotations/ingressclass.kubernetes.io~1is-default-class"
        value: "${var.is-default}"
    EOF
  }
  patches {
    target {
      kind = "Service"
      name = "traefik"
    }
    patch = <<-EOF
apiVersion: v1
kind: Service
metadata:
  name: traefik
spec:
  type: LoadBalancer
  externalTrafficPolicy: Local
  ipFamilyPolicy: PreferDualStack
    EOF
  }
}
