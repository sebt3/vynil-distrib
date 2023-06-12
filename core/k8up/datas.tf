
data "kustomization_overlay" "data" {
  resources = [ for file in fileset(path.module, "*.yaml"): file if file != "index.yaml"]
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
  patches {
    target {
      kind = "PrometheusRule"
      name = "k8up-rule"
      namespace = "k8up"
    }
    patch = <<-EOF
      apiVersion: monitoring.coreos.com/v1
      kind: PrometheusRule
      metadata:
        name: k8up-rule
        namespace: "${var.namespace}"
    EOF
  }
  patches {
    target {
      kind = "ServiceMonitor"
      name = "k8up-monitor"
      namespace = "k8up"
    }
    patch = <<-EOF
      apiVersion: monitoring.coreos.com/v1
      kind: ServiceMonitor
      metadata:
        name: k8up-monitor
        namespace: "${var.namespace}"
    EOF
  }
  patches {
    target {
      kind = "Service"
      name = "k8up-metrics"
    }
    patch = <<-EOF
      apiVersion: v1
      kind: Service
      metadata:
        name: k8up-metrics
        namespace: "${var.namespace}"
    EOF
  }
  patches {
    target {
      kind = "ServiceAccount"
      name = "k8up"
    }
    patch = <<-EOF
      apiVersion: v1
      kind: ServiceAccount
      metadata:
        name: k8up
        namespace: "${var.namespace}"
    EOF
  }
}
