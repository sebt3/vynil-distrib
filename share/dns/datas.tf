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
  items = concat([{
    "key"  = "Corefile"
    "path" = "Corefile"
  }],[for z in var.zones: {
    "key"  = z.name
    "path" = z.name
  }])
}

data "kustomization_overlay" "data" {
  namespace = var.namespace
  common_labels = local.common-labels
  resources = [for file in fileset(path.module, "*.yaml"): file if file != "index.yaml"]
  images {
    name = "coredns/coredns"
    new_name = "${var.image.registry}/${var.image.repository}"
    new_tag  = "${var.image.tag}"
  }
  patches {
    target {
      kind = "Deployment"
      name = "coredns-coredns"
    }
    patch = <<-EOF
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: coredns-coredns
      spec:
        template:
          spec:
            containers:
            - name: coredns
              image: "${var.image.registry}/${var.image.repository}:${var.image.tag}"
              imagePullPolicy: "${var.image.pullPolicy}"
            volumes:
            - name: config-volume
              configMap:
                name: "${var.component}-${var.instance}"
                items: ${jsonencode(local.items)}
    EOF
  }
}
