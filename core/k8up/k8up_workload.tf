resource "kubectl_manifest" "Deployment_k8up" {
  yaml_body  = <<-EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: "${var.instance}-${var.component}"
      labels: ${jsonencode(local.k8up_all_labels)}
      namespace: ${var.namespace}
    spec:
      replicas: 1
      selector:
        matchLabels: ${jsonencode(local.k8up_labels)}
      template:
        metadata:
          labels: ${jsonencode(local.k8up_labels)}
        spec:
          securityContext: {}
          containers:
          - name: k8up-operator
            image: ${var.images.operator.registry}/${var.images.operator.repository}:${var.images.operator.tag}
            imagePullPolicy: "${var.images.operator.pullPolicy}"
            args:
            - operator
            env:
            - name: BACKUP_IMAGE
              value: "${var.images.backup.registry}/${var.images.backup.repository}:${var.images.backup.tag}"
            - name: TZ
              value: "${var.timezone}"
            - name: BACKUP_ENABLE_LEADER_ELECTION
              value: 'true'
            - name: BACKUP_SKIP_WITHOUT_ANNOTATION
              value: 'false'
            - name: BACKUP_OPERATOR_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            ports:
            - name: http
              containerPort: 8080
            livenessProbe:
              httpGet:
                path: /metrics
                port: http
              initialDelaySeconds: 30
              periodSeconds: 10
            securityContext: {}
            resources:
              limits:
                cpu: "${var.resources.limits.cpu}"
                memory: "${var.resources.limits.memory}"
              requests:
                cpu: "${var.resources.requests.cpu}"
                memory: "${var.resources.requests.memory}"
          serviceAccountName: ${kubectl_manifest.sa.name}
EOF
}

