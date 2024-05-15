resource "kubectl_manifest" "webhook" {
  yaml_body  = <<-EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: "${var.instance}-${var.component}-webhook"
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common-labels)}
    spec:
      selector:
        matchLabels:
          app.kubernetes.io/name: ${var.component}
          app.kubernetes.io/instance: ${var.instance}
          app.kubernetes.io/component: webhook
      template:
        metadata:
          labels:
            app.kubernetes.io/name: ${var.component}
            app.kubernetes.io/instance: ${var.instance}
            app.kubernetes.io/component: webhook
        spec:
          serviceAccountName: ${kubectl_manifest.webhook_sa.name}
          containers:
          - name: ndb-operator-webhook
            image: "${var.image.registry}/${var.image.repository}:${var.image.tag}"
            imagePullPolicy: "${var.image.pull_policy}"
            ports:
            - containerPort: 9443
            command:
            - ndb-operator-webhook
            args:
            - -service=${var.instance}-${var.component}-webhook
            readinessProbe:
              httpGet:
                path: /health
                port: 9443
                scheme: HTTPS
      strategy:
        rollingUpdate:
          maxUnavailable: 0
EOF
}

resource "kubectl_manifest" "operator" {
  yaml_body  = <<-EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: "${var.instance}-${var.component}-operator"
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common-labels)}
    spec:
      replicas: 1
      selector:
        matchLabels:
          app.kubernetes.io/name: ${var.component}
          app.kubernetes.io/instance: ${var.instance}
          app.kubernetes.io/component: operator
      template:
        metadata:
          labels:
            app.kubernetes.io/name: ${var.component}
            app.kubernetes.io/instance: ${var.instance}
            app.kubernetes.io/component: operator
        spec:
          serviceAccountName: ${kubectl_manifest.operator_sa.name}
          hostname: ndb-operator-pod
          subdomain: ndb-operator-svc
          containers:
          - name: ndb-operator-controller
            image: "${var.image.registry}/${var.image.repository}:${var.image.tag}"
            imagePullPolicy: "${var.image.pull_policy}"
            command:
            - ndb-operator
            args:
            - -cluster-scoped=true
            ports:
            - containerPort: 1186
            env:
            - name: NDB_OPERATOR_IMAGE
              value: "${var.image.registry}/${var.image.repository}:${var.image.tag}"
            - name: NDB_OPERATOR_IMAGE_PULL_SECRET_NAME
              value: null
      strategy:
        rollingUpdate:
          maxUnavailable: 0
EOF
}

