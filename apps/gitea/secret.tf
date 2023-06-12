
resource "kubernetes_manifest" "gitea_secret" {
  manifest = {
    apiVersion = "secretgenerator.mittwald.de/v1alpha1"
    kind       = "StringSecret"
    metadata = {
      name      = "gitea-admin-user"
      namespace = var.namespace
      labels    = local.common-labels
    }
    spec = {
      forceRegenerate = false,
      data = {
        username = var.admin.name
      }
      fields = [
        {
          fieldName = "password"
          length    = "32"
        }
      ]
    }
  }
}
