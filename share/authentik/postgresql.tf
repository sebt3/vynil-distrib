resource "kubectl_manifest" "authentik_postgresql" {
  yaml_body  = <<-EOF
    apiVersion: "acid.zalan.do/v1"
    kind: "postgresql"
    metadata:
      name: "${var.instance}-${var.component}"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      databases:
        ${var.component}: "${var.component}"
      numberOfInstances: ${var.postgres.replicas}
      podAnnotations:
        "k8up.io/backupcommand": "pg_dump -U postgres -d ${var.component} --clean"
        "k8up.io/file-extension": ".sql"
      postgresql:
        version: "${var.postgres.version}"
      teamId: "${var.instance}"
      users:
        ${var.component}:
          - "superuser"
          - "createdb"
      volume:
        size: "${var.postgres.storage}"
  EOF
}
