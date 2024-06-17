resource "kubectl_manifest" "Deployment_pinniped-supervisor" {
  yaml_body  = <<-EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: pinniped-supervisor
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: pinniped-supervisor
      template:
        metadata:
          labels:
            app: pinniped-supervisor
            deployment.pinniped.dev: supervisor
        spec:
          securityContext:
            runAsUser: 65532
            runAsGroup: 65532
          serviceAccountName: pinniped-supervisor
          containers:
          - name: pinniped-supervisor
            image: ghcr.io/vmware-tanzu/pinniped/pinniped-server:v0.32.0@sha256:f76fa757678f1ab2492be698dc33afbec5ce22b32eebb8a648d5196f9e63ce35
            imagePullPolicy: IfNotPresent
            command:
            - pinniped-supervisor
            - /etc/podinfo
            - /etc/config/pinniped.yaml
            securityContext:
              readOnlyRootFilesystem: true
              runAsNonRoot: true
              allowPrivilegeEscalation: false
              capabilities:
                drop:
                - ALL
              seccompProfile:
                type: RuntimeDefault
            resources:
              requests:
                cpu: 100m
                memory: 128Mi
              limits:
                cpu: 1000m
                memory: 128Mi
            volumeMounts:
            - name: config-volume
              mountPath: /etc/config
              readOnly: true
            - name: podinfo
              mountPath: /etc/podinfo
              readOnly: true
            ports:
            - containerPort: 8443
              protocol: TCP
            env: []
            livenessProbe:
              httpGet:
                path: /healthz
                port: 8443
                scheme: HTTPS
              initialDelaySeconds: 2
              timeoutSeconds: 15
              periodSeconds: 10
              failureThreshold: 5
            readinessProbe:
              httpGet:
                path: /healthz
                port: 8443
                scheme: HTTPS
              initialDelaySeconds: 2
              timeoutSeconds: 3
              periodSeconds: 10
              failureThreshold: 3
          volumes:
          - name: config-volume
            configMap:
              name: pinniped-supervisor-static-config
          - name: podinfo
            downwardAPI:
              items:
              - path: labels
                fieldRef:
                  fieldPath: metadata.labels
              - path: namespace
                fieldRef:
                  fieldPath: metadata.namespace
              - path: name
                fieldRef:
                  fieldPath: metadata.name
          tolerations:
          - key: kubernetes.io/arch
            effect: NoSchedule
            operator: Equal
            value: amd64
          - key: kubernetes.io/arch
            effect: NoSchedule
            operator: Equal
            value: arm64
          affinity:
            podAntiAffinity:
              preferredDuringSchedulingIgnoredDuringExecution:
              - weight: 50
                podAffinityTerm:
                  labelSelector:
                    matchLabels:
                      deployment.pinniped.dev: supervisor
                  topologyKey: kubernetes.io/hostname
EOF
}

