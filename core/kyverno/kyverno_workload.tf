resource "kubectl_manifest" "Deployment_kyverno-background-controller" {
  yaml_body  = <<-EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: kyverno-background-controller
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      replicas: null
      revisionHistoryLimit: 10
      strategy:
        rollingUpdate:
          maxSurge: 1
          maxUnavailable: 40%
        type: RollingUpdate
      selector:
        matchLabels:
          app.kubernetes.io/component: background-controller
          app.kubernetes.io/instance: kyverno
          app.kubernetes.io/part-of: kyverno
      template:
        metadata:
          labels:
            app.kubernetes.io/component: background-controller
            app.kubernetes.io/instance: kyverno
            app.kubernetes.io/managed-by: Helm
            app.kubernetes.io/part-of: kyverno
            app.kubernetes.io/version: 3.2.5
            helm.sh/chart: kyverno-3.2.5
        spec:
          dnsPolicy: ClusterFirst
          affinity:
            podAntiAffinity:
              preferredDuringSchedulingIgnoredDuringExecution:
              - podAffinityTerm:
                  labelSelector:
                    matchExpressions:
                    - key: app.kubernetes.io/component
                      operator: In
                      values:
                      - background-controller
                  topologyKey: kubernetes.io/hostname
                weight: 1
          serviceAccountName: kyverno-background-controller
          containers:
          - name: controller
            image: ${var.images.background.registry}/${var.images.background.repository}:${var.images.background.tag}
            imagePullPolicy: ${var.images.background.pull_policy}
            ports:
            - containerPort: 9443
              name: https
              protocol: TCP
            - containerPort: 8000
              name: metrics
              protocol: TCP
            args:
            - --disableMetrics=false
            - --otelConfig=prometheus
            - --metricsPort=8000
            - --enableConfigMapCaching=true
            - --enableDeferredLoading=true
            - --maxAPICallResponseLength=2000000
            - --loggingFormat=text
            - --v=2
            - --omitEvents=PolicyApplied,PolicySkipped
            - --enablePolicyException=true
            env:
            - name: KYVERNO_SERVICEACCOUNT_NAME
              value: kyverno-background-controller
            - name: KYVERNO_DEPLOYMENT
              value: kyverno-background-controller
            - name: INIT_CONFIG
              value: kyverno
            - name: METRICS_CONFIG
              value: kyverno-metrics
            - name: KYVERNO_POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: KYVERNO_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            resources:
              limits:
                memory: 128Mi
              requests:
                cpu: 100m
                memory: 64Mi
            securityContext:
              allowPrivilegeEscalation: false
              capabilities:
                drop:
                - ALL
              privileged: false
              readOnlyRootFilesystem: true
              runAsNonRoot: true
              seccompProfile:
                type: RuntimeDefault
EOF
}

resource "kubectl_manifest" "Deployment_kyverno-reports-controller" {
  yaml_body  = <<-EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: kyverno-reports-controller
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      replicas: null
      revisionHistoryLimit: 10
      strategy:
        rollingUpdate:
          maxSurge: 1
          maxUnavailable: 40%
        type: RollingUpdate
      selector:
        matchLabels:
          app.kubernetes.io/component: reports-controller
          app.kubernetes.io/instance: kyverno
          app.kubernetes.io/part-of: kyverno
      template:
        metadata:
          labels:
            app.kubernetes.io/component: reports-controller
            app.kubernetes.io/instance: kyverno
            app.kubernetes.io/managed-by: Helm
            app.kubernetes.io/part-of: kyverno
            app.kubernetes.io/version: 3.2.5
            helm.sh/chart: kyverno-3.2.5
        spec:
          dnsPolicy: ClusterFirst
          affinity:
            podAntiAffinity:
              preferredDuringSchedulingIgnoredDuringExecution:
              - podAffinityTerm:
                  labelSelector:
                    matchExpressions:
                    - key: app.kubernetes.io/component
                      operator: In
                      values:
                      - reports-controller
                  topologyKey: kubernetes.io/hostname
                weight: 1
          serviceAccountName: kyverno-reports-controller
          containers:
          - name: controller
            image: ${var.images.reports.registry}/${var.images.reports.repository}:${var.images.reports.tag}
            imagePullPolicy: ${var.images.reports.pull_policy}
            ports:
            - containerPort: 9443
              name: https
              protocol: TCP
            - containerPort: 8000
              name: metrics
              protocol: TCP
            args:
            - --disableMetrics=false
            - --otelConfig=prometheus
            - --metricsPort=8000
            - --admissionReports=true
            - --aggregateReports=true
            - --policyReports=true
            - --validatingAdmissionPolicyReports=false
            - --backgroundScan=true
            - --backgroundScanWorkers=2
            - --backgroundScanInterval=1h
            - --skipResourceFilters=true
            - --enableConfigMapCaching=true
            - --enableDeferredLoading=true
            - --maxAPICallResponseLength=2000000
            - --loggingFormat=text
            - --v=2
            - --omitEvents=PolicyApplied,PolicySkipped
            - --enablePolicyException=true
            - --reportsChunkSize=0
            - --allowInsecureRegistry=false
            - --registryCredentialHelpers=default,google,amazon,azure,github
            env:
            - name: KYVERNO_SERVICEACCOUNT_NAME
              value: kyverno-reports-controller
            - name: KYVERNO_DEPLOYMENT
              value: kyverno-reports-controller
            - name: INIT_CONFIG
              value: kyverno
            - name: METRICS_CONFIG
              value: kyverno-metrics
            - name: KYVERNO_POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: KYVERNO_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: TUF_ROOT
              value: /.sigstore
            resources:
              limits:
                memory: 128Mi
              requests:
                cpu: 100m
                memory: 64Mi
            securityContext:
              allowPrivilegeEscalation: false
              capabilities:
                drop:
                - ALL
              privileged: false
              readOnlyRootFilesystem: true
              runAsNonRoot: true
              seccompProfile:
                type: RuntimeDefault
            volumeMounts:
            - mountPath: /.sigstore
              name: sigstore
          volumes:
          - name: sigstore
            emptyDir: {}
EOF
}

resource "kubectl_manifest" "Deployment_kyverno-admission-controller" {
  yaml_body  = <<-EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: kyverno-admission-controller
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      replicas: null
      revisionHistoryLimit: 10
      strategy:
        rollingUpdate:
          maxSurge: 1
          maxUnavailable: 40%
        type: RollingUpdate
      selector:
        matchLabels:
          app.kubernetes.io/component: admission-controller
          app.kubernetes.io/instance: kyverno
          app.kubernetes.io/part-of: kyverno
      template:
        metadata:
          labels:
            app.kubernetes.io/component: admission-controller
            app.kubernetes.io/instance: kyverno
            app.kubernetes.io/managed-by: Helm
            app.kubernetes.io/part-of: kyverno
            app.kubernetes.io/version: 3.2.5
            helm.sh/chart: kyverno-3.2.5
        spec:
          dnsPolicy: ClusterFirst
          affinity:
            podAntiAffinity:
              preferredDuringSchedulingIgnoredDuringExecution:
              - podAffinityTerm:
                  labelSelector:
                    matchExpressions:
                    - key: app.kubernetes.io/component
                      operator: In
                      values:
                      - admission-controller
                  topologyKey: kubernetes.io/hostname
                weight: 1
          serviceAccountName: kyverno-admission-controller
          initContainers:
          - name: kyverno-pre
            image: ${var.images.pre.registry}/${var.images.pre.repository}:${var.images.pre.tag}
            imagePullPolicy: ${var.images.pre.pull_policy}
            args:
            - --loggingFormat=text
            - --v=2
            resources:
              limits:
                cpu: 100m
                memory: 256Mi
              requests:
                cpu: 10m
                memory: 64Mi
            securityContext:
              allowPrivilegeEscalation: false
              capabilities:
                drop:
                - ALL
              privileged: false
              readOnlyRootFilesystem: true
              runAsNonRoot: true
              seccompProfile:
                type: RuntimeDefault
            env:
            - name: KYVERNO_SERVICEACCOUNT_NAME
              value: kyverno-admission-controller
            - name: INIT_CONFIG
              value: kyverno
            - name: METRICS_CONFIG
              value: kyverno-metrics
            - name: KYVERNO_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: KYVERNO_POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: KYVERNO_DEPLOYMENT
              value: kyverno-admission-controller
            - name: KYVERNO_SVC
              value: kyverno-svc
          containers:
          - name: kyverno
            image: ${var.images.kyverno.registry}/${var.images.kyverno.repository}:${var.images.kyverno.tag}
            imagePullPolicy: ${var.images.kyverno.pull_policy}
            args:
            - --caSecretName=kyverno-svc.${var.namespace}.svc.kyverno-tls-ca
            - --tlsSecretName=kyverno-svc.${var.namespace}.svc.kyverno-tls-pair
            - --backgroundServiceAccountName=system:serviceaccount:${var.namespace}:kyverno-background-controller
            - --servicePort=443
            - --webhookServerPort=9443
            - --disableMetrics=false
            - --otelConfig=prometheus
            - --metricsPort=8000
            - --admissionReports=true
            - --autoUpdateWebhooks=true
            - --enableConfigMapCaching=true
            - --enableDeferredLoading=true
            - --dumpPayload=false
            - --forceFailurePolicyIgnore=false
            - --generateValidatingAdmissionPolicy=false
            - --maxAPICallResponseLength=2000000
            - --loggingFormat=text
            - --v=2
            - --omitEvents=PolicyApplied,PolicySkipped
            - --enablePolicyException=true
            - --protectManagedResources=false
            - --allowInsecureRegistry=false
            - --registryCredentialHelpers=default,google,amazon,azure,github
            resources:
              limits:
                memory: 384Mi
              requests:
                cpu: 100m
                memory: 128Mi
            securityContext:
              allowPrivilegeEscalation: false
              capabilities:
                drop:
                - ALL
              privileged: false
              readOnlyRootFilesystem: true
              runAsNonRoot: true
              seccompProfile:
                type: RuntimeDefault
            ports:
            - containerPort: 9443
              name: https
              protocol: TCP
            - containerPort: 8000
              name: metrics-port
              protocol: TCP
            env:
            - name: INIT_CONFIG
              value: kyverno
            - name: METRICS_CONFIG
              value: kyverno-metrics
            - name: KYVERNO_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: KYVERNO_POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: KYVERNO_SERVICEACCOUNT_NAME
              value: kyverno-admission-controller
            - name: KYVERNO_SVC
              value: kyverno-svc
            - name: TUF_ROOT
              value: /.sigstore
            - name: KYVERNO_DEPLOYMENT
              value: kyverno-admission-controller
            startupProbe:
              failureThreshold: 20
              httpGet:
                path: /health/liveness
                port: 9443
                scheme: HTTPS
              initialDelaySeconds: 2
              periodSeconds: 6
            livenessProbe:
              failureThreshold: 2
              httpGet:
                path: /health/liveness
                port: 9443
                scheme: HTTPS
              initialDelaySeconds: 15
              periodSeconds: 30
              successThreshold: 1
              timeoutSeconds: 5
            readinessProbe:
              failureThreshold: 6
              httpGet:
                path: /health/readiness
                port: 9443
                scheme: HTTPS
              initialDelaySeconds: 5
              periodSeconds: 10
              successThreshold: 1
              timeoutSeconds: 5
            volumeMounts:
            - mountPath: /.sigstore
              name: sigstore
          volumes:
          - name: sigstore
            emptyDir: {}
EOF
}

resource "kubectl_manifest" "Deployment_kyverno-cleanup-controller" {
  yaml_body  = <<-EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: kyverno-cleanup-controller
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      replicas: null
      revisionHistoryLimit: 10
      strategy:
        rollingUpdate:
          maxSurge: 1
          maxUnavailable: 40%
        type: RollingUpdate
      selector:
        matchLabels:
          app.kubernetes.io/component: cleanup-controller
          app.kubernetes.io/instance: kyverno
          app.kubernetes.io/part-of: kyverno
      template:
        metadata:
          labels:
            app.kubernetes.io/component: cleanup-controller
            app.kubernetes.io/instance: kyverno
            app.kubernetes.io/managed-by: Helm
            app.kubernetes.io/part-of: kyverno
            app.kubernetes.io/version: 3.2.5
            helm.sh/chart: kyverno-3.2.5
        spec:
          dnsPolicy: ClusterFirst
          affinity:
            podAntiAffinity:
              preferredDuringSchedulingIgnoredDuringExecution:
              - podAffinityTerm:
                  labelSelector:
                    matchExpressions:
                    - key: app.kubernetes.io/component
                      operator: In
                      values:
                      - cleanup-controller
                  topologyKey: kubernetes.io/hostname
                weight: 1
          serviceAccountName: kyverno-cleanup-controller
          containers:
          - name: controller
            image: ${var.images.cleanup.registry}/${var.images.cleanup.repository}:${var.images.cleanup.tag}
            imagePullPolicy: ${var.images.cleanup.pull_policy}
            ports:
            - containerPort: 9443
              name: https
              protocol: TCP
            - containerPort: 8000
              name: metrics
              protocol: TCP
            args:
            - --caSecretName=kyverno-cleanup-controller.${var.namespace}.svc.kyverno-tls-ca
            - --tlsSecretName=kyverno-cleanup-controller.${var.namespace}.svc.kyverno-tls-pair
            - --servicePort=443
            - --cleanupServerPort=9443
            - --webhookServerPort=9443
            - --disableMetrics=false
            - --otelConfig=prometheus
            - --metricsPort=8000
            - --enableDeferredLoading=true
            - --dumpPayload=false
            - --maxAPICallResponseLength=2000000
            - --loggingFormat=text
            - --v=2
            - --protectManagedResources=false
            - --ttlReconciliationInterval=1m
            env:
            - name: KYVERNO_DEPLOYMENT
              value: kyverno-cleanup-controller
            - name: INIT_CONFIG
              value: kyverno
            - name: METRICS_CONFIG
              value: kyverno-metrics
            - name: KYVERNO_POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: KYVERNO_SERVICEACCOUNT_NAME
              value: kyverno-cleanup-controller
            - name: KYVERNO_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: KYVERNO_SVC
              value: kyverno-cleanup-controller
            resources:
              limits:
                memory: 128Mi
              requests:
                cpu: 100m
                memory: 64Mi
            securityContext:
              allowPrivilegeEscalation: false
              capabilities:
                drop:
                - ALL
              privileged: false
              readOnlyRootFilesystem: true
              runAsNonRoot: true
              seccompProfile:
                type: RuntimeDefault
            startupProbe:
              failureThreshold: 20
              httpGet:
                path: /health/liveness
                port: 9443
                scheme: HTTPS
              initialDelaySeconds: 2
              periodSeconds: 6
            livenessProbe:
              failureThreshold: 2
              httpGet:
                path: /health/liveness
                port: 9443
                scheme: HTTPS
              initialDelaySeconds: 15
              periodSeconds: 30
              successThreshold: 1
              timeoutSeconds: 5
            readinessProbe:
              failureThreshold: 6
              httpGet:
                path: /health/readiness
                port: 9443
                scheme: HTTPS
              initialDelaySeconds: 5
              periodSeconds: 10
              successThreshold: 1
              timeoutSeconds: 5
EOF
}

