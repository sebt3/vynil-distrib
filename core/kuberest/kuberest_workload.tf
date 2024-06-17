resource "kubectl_manifest" "Deployment_kuberest" {
  yaml_body  = <<-EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels: ${jsonencode(local.common_labels)}
      name: kuberest
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      replicas: 1
      selector:
        matchLabels: ${jsonencode(local.selector)}
      template:
        metadata:
          annotations:
            kubectl.kubernetes.io/default-container: kuberest
          labels: ${jsonencode(local.selector)}
        spec:
          containers:
          - env:
            - name: RUST_LOG
              value: info,kube=info,controller=info
            - name: MULTI_TENANT
              value: '${jsonencode(var.multi_tenant)}'
            image: ${var.images.operator.registry}/${var.images.operator.repository}:${var.images.operator.tag}
            imagePullPolicy: ${var.images.operator.pull_policy}
            name: kuberest
            ports:
            - containerPort: 8080
              name: http
              protocol: TCP
            readinessProbe:
              httpGet:
                path: /health
                port: http
              initialDelaySeconds: 5
              periodSeconds: 5
            resources:
              limits:
                cpu: 500m
                memory: 512Mi
              requests:
                cpu: 50m
                memory: 100Mi
            securityContext: {}
          securityContext: {}
          serviceAccountName: kuberest
EOF
}

