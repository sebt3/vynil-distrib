resource "kubectl_manifest" "Service_vynil-controller" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Service
    metadata:
      name: vynil-controller
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
    spec:
      ports:
      - port: 80
        targetPort: 9000
        protocol: TCP
        name: http
      selector:
        app: vynil-controller
EOF
}

resource "kubectl_manifest" "Deployment_vynil-controller" {
  yaml_body  = <<-EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: vynil-controller
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: vynil-controller
      template:
        metadata:
          labels:
            app: vynil-controller
          annotations:
            prometheus.io/scrape: 'true'
            prometheus.io/port: '9000'
        spec:
          serviceAccountName: vynil-controller
          containers:
          - name: vynil-controller
            image: ${var.images.operator.registry}/${var.images.operator.repository}:${var.images.operator.tag}
            imagePullPolicy: ${var.images.operator.pullPolicy}
            resources:
              requests:
                cpu: "${var.resources.requests.cpu}"
                memory: "${var.resources.requests.memory}"
            ports:
            - name: http
              containerPort: 9000
              protocol: TCP
            env:
            - name: RUST_BACKTRACE
              value: '1'
            - name: RUST_LOG
              value: info,controller=info
            - name: AGENT_IMAGE
              value: "${var.images.agent.registry}/${var.images.agent.repository}:${var.images.agent.tag}"
            readinessProbe:
              httpGet:
                path: /health
                port: http
              initialDelaySeconds: 5
              periodSeconds: 5
EOF
}

