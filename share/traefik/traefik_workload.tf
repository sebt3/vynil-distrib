locals {
  traefik_args = concat(
    [
      "--entryPoints.websecure.address=:8443/tcp",
      "--entryPoints.websecure.http.tls=true",
      "--entryPoints.web.address=:8000/tcp",
      "--entryPoints.metrics.address=:9100/tcp",
      "--entryPoints.traefik.address=:9000/tcp",
      "--ping=true",
      "--metrics.prometheus=true",
      "--metrics.prometheus.entrypoint=metrics",
      "--metrics.prometheus.addRoutersLabels=true",
      "--log.level=INFO",
      "--api.insecure=true",
      "--api.dashboard=true",
      "--providers.kubernetescrd",
      "--providers.kubernetescrd.allowExternalNameServices=true",
      "--providers.kubernetesingress",
      "--providers.kubernetesingress.allowExternalNameServices=true",
      "--providers.kubernetesingress.ingressendpoint.publishedservice=${var.namespace}/traefik",
      "--providers.kubernetesingress.ingressclass=${var.ingressClass}",
      "--global.checknewversion=false",
      "--global.sendanonymoususage=false"
    ],
    var.use_plugins?[
      "--experimental.plugins.fail2ban.moduleName=github.com/tomMoulard/fail2ban",
      "--experimental.plugins.fail2ban.version=v0.7.1",
      "--experimental.plugins.ldapAuth.moduleName=github.com/wiltonsr/ldapAuth",
      "--experimental.plugins.ldapAuth.version=v0.1.8",
      "--experimental.plugins.redirect2https.moduleName=github.com/sunalwaysknows/redirect2https",
      "--experimental.plugins.redirect2https.version=v0.0.7",
    ]:[],
    var.conditions.have_gateway?[
      "--providers.kubernetesgateway",
      "--experimental.kubernetesgateway",
    ]:[]
  )
}
resource "kubectl_manifest" "DaemonSet_traefik" {
  yaml_body  = <<-EOF
    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
      name: traefik
      namespace: ${var.namespace}
      labels: ${jsonencode(local.traefik_all_labels)}
    spec:
      selector:
        matchLabels: ${jsonencode(local.common_labels)}
      updateStrategy:
        rollingUpdate:
          maxSurge: 1
          maxUnavailable: 0
        type: RollingUpdate
      minReadySeconds: 0
      template:
        metadata:
          annotations:
            prometheus.io/scrape: 'true'
            prometheus.io/path: /metrics
            prometheus.io/port: '9100'
          labels: ${jsonencode(local.common_labels)}
        spec:
          serviceAccountName: ${kubectl_manifest.sa.name}
          terminationGracePeriodSeconds: 60
          hostNetwork: false
          containers:
          - name: traefik
            image: "${var.image.registry}/${var.image.repository}:${var.image.tag}"
            imagePullPolicy: "${var.image.pullPolicy}"
            resources: null
            args: ${jsonencode(local.traefik_args)}
            readinessProbe:
              httpGet:
                path: /ping
                port: 9000
                scheme: HTTP
              failureThreshold: 1
              initialDelaySeconds: 2
              periodSeconds: 10
              successThreshold: 1
              timeoutSeconds: 2
            livenessProbe:
              httpGet:
                path: /ping
                port: 9000
                scheme: HTTP
              failureThreshold: 3
              initialDelaySeconds: 2
              periodSeconds: 10
              successThreshold: 1
              timeoutSeconds: 2
            lifecycle: null
            ports:
            - name: metrics
              containerPort: 9100
              protocol: TCP
            - name: traefik
              containerPort: 9000
              protocol: TCP
            - name: web
              containerPort: 8000
              protocol: TCP
            - name: websecure
              containerPort: 8443
              protocol: TCP
            securityContext:
              allowPrivilegeEscalation: false
              capabilities:
                drop:
                - ALL
              readOnlyRootFilesystem: true
            volumeMounts:
            - name: data
              mountPath: /data
            - name: tmp
              mountPath: /tmp
            - name: plugins
              mountPath: /plugins-storage
            env:
            - name: TZ
              value: Europe/Paris
          volumes:
          - name: data
            emptyDir: {}
          - name: tmp
            emptyDir: {}
          - name: plugins
            emptyDir: {}
          tolerations:
          - key: CriticalAddonsOnly
            operator: Exists
          - effect: NoSchedule
            key: node-role.kubernetes.io/control-plane
            operator: Exists
          - effect: NoSchedule
            key: node-role.kubernetes.io/master
            operator: Exists
          priorityClassName: system-cluster-critical
          securityContext:
            fsGroupChangePolicy: OnRootMismatch
            runAsGroup: 65532
            runAsNonRoot: true
            runAsUser: 65532
EOF
}

