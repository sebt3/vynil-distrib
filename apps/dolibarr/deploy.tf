locals {
  deploy-labels = merge(local.common-labels, {
    "app.kubernetes.io/component" = "dolibarr"
  })
}
resource "kubectl_manifest" "hpa" {
  yaml_body  = <<-EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ${var.instance}
  namespace: ${var.namespace}
  labels: ${jsonencode(local.deploy-labels)}
spec:
  minReplicas: ${var.hpa.min-replicas}
  maxReplicas: ${var.hpa.max-replicas}
  metrics:
  - resource:
      name: cpu
      target:
        averageUtilization: ${var.hpa.avg-cpu}
        type: Utilization
    type: Resource
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ${var.instance}
  EOF
}

resource "kubectl_manifest" "deploy" {
  yaml_body  = <<-EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${var.instance}
  namespace: ${var.namespace}
  labels: ${jsonencode(local.deploy-labels)}
spec:
  selector:
    matchLabels: ${jsonencode(local.deploy-labels)}
  template:
    metadata:
      labels: ${jsonencode(local.deploy-labels)}
    spec:
      securityContext:
        runAsGroup: 82
        runAsUser: 82
        fsGroup: 82
      volumes:
      - name: config-json
        configMap:
          name: ${kubectl_manifest.config-json.name}
      - name: documents
        persistentVolumeClaim:
          claimName: ${kubectl_manifest.pvc.name}
      - name: nginx-run
        emptyDir: {}
      - name: nginx-cache
        emptyDir: {}
      - name: shared-files
        emptyDir: {}
      - name: shared-logs
        emptyDir: {}
      - name: nginx-config
        configMap:
          name: ${kubectl_manifest.nginx-config.name}
      - name: saml-cert
        secret:
          secretName: "${kubectl_manifest.saml_certificate.name}"
      initContainers:
      - name: configure
        args:
        - echo
        - SUCCESS
        image: "${var.images.dolibarr.registry}/${var.images.dolibarr.repository}:${var.images.dolibarr.tag}"
        imagePullPolicy: "${var.images.dolibarr.pullPolicy}"
        volumeMounts:
        - name: shared-files
          mountPath: /var/www/
        - name: shared-logs
          mountPath: /var/logs/
        - name: documents
          mountPath: /var/documents
        - name: config-json
          mountPath: /etc/config/config.json
          subPath: config.json
        - name: config-json
          mountPath: /docker-entrypoint.d/vynil-configurator.sh
          subPath: vynil-configurator.sh
        securityContext:
          runAsNonRoot: true
        env:
        - name: DOLI_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              key: password
              name: "${var.component}.${var.instance}-${var.component}.credentials.postgresql.acid.zalan.do"
        envFrom:
        - configMapRef:
            name: "${kubectl_manifest.config.name}"
        - secretRef:
            name: "${kubectl_manifest.dolibarr_ldap.name}"
      containers:
      - name: dolibarr
        command:
        - "/usr/local/sbin/php-fpm"
        image: "${var.images.dolibarr.registry}/${var.images.dolibarr.repository}:${var.images.dolibarr.tag}"
        imagePullPolicy: "${var.images.dolibarr.pullPolicy}"
        resources: ${jsonencode(var.resources)}
        readinessProbe:
          httpGet:
            path: /index.php
            port: 3000
            scheme: HTTP
          periodSeconds: 10
          timeoutSeconds: 1
          successThreshold: 1
          failureThreshold: 3
        livenessProbe:
          httpGet:
            path: /index.php
            port: 3000
            scheme: HTTP
          periodSeconds: 10
          timeoutSeconds: 1
          failureThreshold: 3
          successThreshold: 1
        volumeMounts:
        - name: shared-logs
          mountPath: /var/logs/
        - name: shared-files
          mountPath: /var/www/
        - name: documents
          mountPath: /var/documents
        - name: saml-cert
          mountPath: /var/saml
        - name: config-json
          mountPath: /usr/local/etc/php/conf.d/docker-php-ext-redis.ini
          subPath: docker-php-ext-redis.ini
        securityContext:
          runAsNonRoot: true
        env:
        - name: DOLI_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              key: password
              name: "${var.component}.${var.instance}-${var.component}.credentials.postgresql.acid.zalan.do"
        envFrom:
        - configMapRef:
            name: "${kubectl_manifest.config.name}"
        - secretRef:
            name: "${kubectl_manifest.dolibarr_ldap.name}"
      - name: dolibarr-logs
        command:
        - "tail -f /var/logs/dolibarr.log"
        image: "${var.images.dolibarr.registry}/${var.images.dolibarr.repository}:${var.images.dolibarr.tag}"
        imagePullPolicy: "${var.images.dolibarr.pullPolicy}"
        volumeMounts:
        - name: shared-logs
          mountPath: /var/logs/
      - name: nginx
        image: "${var.images.nginx.registry}/${var.images.nginx.repository}:${var.images.nginx.tag}"
        imagePullPolicy: "${var.images.nginx.pullPolicy}"
        securityContext:
          runAsNonRoot: true
          readOnlyRootFilesystem: true
        ports:
        - name: http
          containerPort: 3000
          protocol: TCP
        volumeMounts:
        - name: nginx-run
          mountPath: /var/run
        - name: nginx-cache
          mountPath: /var/cache/nginx
        - name: shared-files
          mountPath: /var/www/
        - name: nginx-config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
  EOF
}
