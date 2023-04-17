
data "kustomization_overlay" "data" {
  namespace = var.namespace
  resources = [ for file in fileset(path.module, "*.yaml"): file if file != "index.yaml"]
  images {
    name = "operator"
    new_name = "${var.images.operator.registry}/${var.images.operator.repository}"
    new_tag = "${var.images.operator.tag}"
  }
  patches {
    target {
      kind = "Deployment"
      name = "vynil-controller"
    }
    patch = <<-EOF
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: vynil-controller
        namespace: default
      spec:
        template:
          spec:
            containers:
            - name: vynil-controller
              imagePullPolicy: "${var.images.operator.pullPolicy}"
              resources:
                limits:
                  cpu: "${var.resources.limits.cpu}"
                  memory: "${var.resources.limits.memory}"
                requests:
                  cpu: "${var.resources.requests.cpu}"
                  memory: "${var.resources.requests.memory}"
              env:
              - name: AGENT_IMAGE
                value: "${var.images.agent.registry}/${var.images.agent.repository}:${var.images.agent.tag}"
    EOF
  }
}
