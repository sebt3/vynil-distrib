
data "kustomization_overlay" "data" {
  namespace = var.namespace
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
