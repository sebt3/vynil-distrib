
data "kustomization_overlay" "data" {
  resources = [ for file in fileset(path.module, "*.yaml"): file if file != "index.yaml"]
}
