resource "kubectl_manifest" "deploy" {
  yaml_body  = <<-EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: ${var.instance}-${var.component}
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
      labels: ${jsonencode(local.common_labels)}
    spec:
      replicas: 1
      selector:
        matchLabels: ${jsonencode(local.secret_selector)}
      template:
        metadata:
          labels: ${jsonencode(local.secret_selector)}
        spec:
          serviceAccountName: ${kubectl_manifest.sa.name}
          containers:
          - name: kubernetes-secret-generator
            image: "${var.image.registry}/${var.image.repository}:${var.image.tag}"
            imagePullPolicy: "${var.image.pull_policy}"
            ports:
            - containerPort: 8080
              name: healthcheck
            livenessProbe:
              httpGet:
                path: /healthz
                port: healthcheck
              initialDelaySeconds: 6
              periodSeconds: 3
            readinessProbe:
              httpGet:
                path: /readyz
                port: healthcheck
              initialDelaySeconds: 6
              periodSeconds: 3
            env:
            - name: WATCH_NAMESPACE
              value: "${var.namespaces}"
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: OPERATOR_NAME
              value: ${var.instance}-${var.component}
            - name: REGENERATE_INSECURE
              value: 'true'
            - name: SECRET_LENGTH
              value: '${var.secret_length}'
            - name: USE_METRICS_SERVICE
              value: 'false'
EOF
}

