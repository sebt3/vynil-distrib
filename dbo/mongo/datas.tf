
data "kustomization_overlay" "data" {
  namespace = var.namespace
  resources = [ for file in [
    "deploy/clusterwide/cluster_role.yaml",
    "deploy/clusterwide/cluster_role_binding.yaml",
    "deploy/clusterwide/role-for-binding.yaml",
    "config/rbac/role.yaml",
    "config/rbac/role_binding.yaml",
    "config/rbac/service_account.yaml",
    "config/rbac/service_account_database.yaml",
    "config/rbac/role_binding_database.yaml",
    "config/rbac/role_database.yaml",
    "config/manager/manager.yaml"
  ]: format("https://raw.githubusercontent.com/mongodb/mongodb-kubernetes-operator/v%s/%s",var.release,file)]
  patches {
    target {
      kind = "Deployment"
      name = "mongodb-kubernetes-operator"
    }
    patch = <<-EOF
    - path: /spec/template/spec/containers/0/env/0/valueFrom
      op: remove
    - path: /spec/template/spec/containers/0/env/0/value
      op: add
      value: "*"
    EOF
  }
}
