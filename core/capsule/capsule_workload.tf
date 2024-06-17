resource "kubectl_manifest" "Deployment_capsule-controller-manager" {
  yaml_body  = <<-EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: capsule-controller-manager
      labels: ${jsonencode(local.common_labels)}
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      replicas: 1
      selector:
        matchLabels: ${jsonencode(local.selector)}
      template:
        metadata:
          labels: ${jsonencode(local.selector)}
        spec:
          serviceAccountName: ${kubectl_manifest.sa.name}
          securityContext:
            runAsGroup: 1002
            runAsNonRoot: true
            runAsUser: 1002
            seccompProfile:
              type: RuntimeDefault
          priorityClassName: null
          volumes:
          - name: cert
            secret:
              defaultMode: 420
              secretName: capsule-tls
          containers:
          - name: manager
            args:
            - --webhook-port=9443
            - --enable-leader-election
            - --zap-log-level=4
            - --configuration-name=default
            image: ${var.images.operator.registry}/${var.images.operator.repository}:${var.images.operator.tag}
            imagePullPolicy: ${var.images.operator.pull_policy}
            env:
            - name: NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            ports:
            - name: webhook-server
              containerPort: 9443
              protocol: TCP
            - name: metrics
              containerPort: 8080
              protocol: TCP
            livenessProbe:
              httpGet:
                path: /healthz
                port: 10080
            readinessProbe:
              httpGet:
                path: /readyz
                port: 10080
            volumeMounts:
            - mountPath: /tmp/k8s-webhook-server/serving-certs
              name: cert
              readOnly: true
            resources: {}
            securityContext:
              allowPrivilegeEscalation: false
              capabilities:
                drop:
                - ALL
              readOnlyRootFilesystem: true
EOF
}

