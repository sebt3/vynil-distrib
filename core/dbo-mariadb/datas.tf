
data "kustomization_overlay" "data" {
  namespace = var.namespace
  resources = concat([
    "https://raw.githubusercontent.com/mariadb-operator/mariadb-operator/v0.0.11/deploy/crds/crds.yaml"
  ],[ for file in fileset(path.module, "*.yaml"): file if file != "index.yaml"])
}
