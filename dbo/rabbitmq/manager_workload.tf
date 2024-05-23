resource "kubectl_manifest" "manager" {
  yaml_body  = <<-EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: "${var.instance}-${var.component}-manager"
      namespace: ${var.namespace}
      labels: ${jsonencode(local.manager_all_labels)}
    spec:
      replicas: 1
      selector:
        matchLabels: ${jsonencode(local.manager_labels)}
      template:
        metadata:
          labels: ${jsonencode(local.manager_labels)}
        spec:
          containers:
          - command:
            - /manager
            env:
            - name: OPERATOR_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            image: "${var.images.manager.registry}/${var.images.manager.repository}:${var.images.manager.tag}"
            imagePullPolicy: ${var.images.manager.pull_policy}
            name: operator
            ports:
            - containerPort: 9782
              name: metrics
              protocol: TCP
            resources:
              limits:
                cpu: 200m
                memory: 500Mi
              requests:
                cpu: 200m
                memory: 500Mi
          serviceAccountName: ${kubectl_manifest.sa_manager.name}
          terminationGracePeriodSeconds: 10
EOF
}

