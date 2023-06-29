resource "kubectl_manifest" "deploy" {
  yaml_body  = <<-EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: "${var.component}-${var.instance}"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    spec:
      replicas: 1
      hostname: "${var.component}-${var.instance}"
      subdomain: "${var.domain-name}"
      selector:
        matchLabels: ${jsonencode(local.common-labels)}
      template:
        metadata:
          labels: ${jsonencode(local.common-labels)}
        spec:
          securityContext:
            fsGroup: 1000
            runAsGroup: 1000
            capabilities:
              add:
              - SETGID
              - SETUID
              - SYS_CHROOT
          hostname: "${var.component}-${var.instance}"
          containers:
          - name: code-server
            securityContext:
              fsGroup: 1000
              runAsGroup: 1000
              runAsNonRoot: true
              runAsUser: 1000
              privileged: true
            env:
            - name: TZ
              value: "${var.timezone}"
            - name: ENTRYPOINTD
              value: /usr/local/startup
            - name: PORT
              value: "8080"
            - name: CODE_SERVER_CONFIG
              value: /etc/code-server/config.yml
            image: "${var.images.codeserver.registry}/${var.images.codeserver.repository}:${var.images.codeserver.tag}"
            imagePullPolicy: "${var.images.codeserver.pullPolicy}"
            ports:
            - containerPort: 8080
              name: http
              protocol: TCP
            livenessProbe:
              failureThreshold: 3
              httpGet:
                path: /
                port: http
                scheme: HTTP
              periodSeconds: 10
              successThreshold: 1
              timeoutSeconds: 1
            readinessProbe:
              failureThreshold: 3
              httpGet:
                path: /
                port: http
                scheme: HTTP
              periodSeconds: 10
              successThreshold: 1
              timeoutSeconds: 1
            volumeMounts:
            - name: config
              mountPath: /etc/code-server/config.yml
              subPath: config.yml
            - name: startup
              mountPath: /usr/local/startup/autostart.sh
              subPath: autostart.sh
            - name: home
              mountPath: /home/coder
            - name: run
              mountPath: /run
          restartPolicy: Always
          securityContext:
            fsGroup: 1000
            runAsGroup: 1000
            runAsNonRoot: true
            runAsUser: 1000
          serviceAccount: "${var.component}-${var.instance}"
          serviceAccountName: "${var.component}-${var.instance}"
          volumes:
          - name: config
            configMap:
              defaultMode: 0420
              name: "${var.component}-${var.instance}"
              items:
              - key: config.yml
                path: config.yml
          - name: startup
            configMap:
              defaultMode: 0755
              name: "${var.component}-${var.instance}"
              items:
              - key: autostart.sh
                path: autostart.sh
          - name: home
            persistentVolumeClaim:
              claimName: "${var.component}-${var.instance}"
          - name: run
            emptyDir: {}
  EOF
}
