resource "kubectl_manifest" "Deployment_hnc-controller-manager" {
  yaml_body  = <<-EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels: ${jsonencode(local.common_labels)}
      name: hnc-controller-manager
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      replicas: 1
      selector:
        matchLabels:
          control-plane: controller-manager
      template:
        metadata:
          annotations:
            prometheus.io/scrape: 'true'
          labels:
            control-plane: controller-manager
        spec:
          serviceAccountName: hnc
          containers:
          - args:
            - --webhook-server-port=9443
            - --metrics-addr=:8080
            - --max-reconciles=10
            - --apiserver-qps-throttle=50
            - --excluded-namespace=kube-system
            - --excluded-namespace=kube-public
            - --excluded-namespace=vynil
            - --excluded-namespace=${var.namespace}
            - --excluded-namespace=kube-node-lease
            - --nopropagation-label=cattle.io/creator=norman
            - --enable-hrq
            - --namespace=${var.namespace}
            command:
            - /manager
            image: ${var.images.operator.registry}/${var.images.operator.repository}:${var.images.operator.tag}
            imagePullPolicy: ${var.images.operator.pull_policy}
            livenessProbe:
              failureThreshold: 1
              timeoutSeconds: 10
              initialDelaySeconds: 15
              periodSeconds: 10
              httpGet:
                path: /healthz
                port: 8081
              periodSeconds: 10
            name: manager
            ports:
            - containerPort: 9443
              name: webhook-server
              protocol: TCP
            - containerPort: 8080
              name: metrics
              protocol: TCP
            - containerPort: 8081
              name: healthz
              protocol: TCP
            readinessProbe:
              timeoutSeconds: 10
              initialDelaySeconds: 15
              periodSeconds: 10
              httpGet:
                path: /readyz
                port: 8081
            resources:
              limits:
                cpu: 100m
                memory: 300Mi
              requests:
                cpu: 100m
                memory: 150Mi
            securityContext:
              allowPrivilegeEscalation: false
              capabilities:
                drop:
                - ALL
              readOnlyRootFilesystem: true
              runAsNonRoot: true
              seccompProfile:
                type: RuntimeDefault
            startupProbe:
              failureThreshold: 100
              timeoutSeconds: 10
              initialDelaySeconds: 15
              periodSeconds: 10
              httpGet:
                path: /readyz
                port: 8081
            volumeMounts:
            - mountPath: /tmp/k8s-webhook-server/serving-certs
              name: cert
              readOnly: true
          securityContext:
            fsGroup: 2000
            runAsNonRoot: true
            runAsUser: 1000
          terminationGracePeriodSeconds: 10
          volumes:
          - name: cert
            secret:
              defaultMode: 420
              secretName: webhook-server-cert
EOF
}

