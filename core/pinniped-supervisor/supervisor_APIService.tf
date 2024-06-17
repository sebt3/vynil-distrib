resource "kubectl_manifest" "APIService_v1alpha1.clientsecret.supervisor.pinniped.dev" {
  yaml_body  = <<-EOF
    apiVersion: apiregistration.k8s.io/v1
    kind: APIService
    metadata:
      name: v1alpha1.clientsecret.supervisor.pinniped.dev
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      version: v1alpha1
      group: clientsecret.supervisor.pinniped.dev
      groupPriorityMinimum: 9900
      versionPriority: 15
      service:
        name: pinniped-supervisor-api
        namespace: pinniped-supervisor
        port: 443
EOF
}

