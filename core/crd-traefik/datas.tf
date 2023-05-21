
data "kustomization_overlay" "data" {
  resources = [
    "github.com/traefik/traefik-helm-chart//traefik/crds/?ref=v${var.release}",
  ]
}
