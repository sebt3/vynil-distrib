locals {
  common-labels = {
    "vynil.solidite.fr/owner-name" = var.instance
    "vynil.solidite.fr/owner-namespace" = var.namespace
    "vynil.solidite.fr/owner-category" = var.category
    "vynil.solidite.fr/owner-component" = var.component
    "app.kubernetes.io/managed-by" = "vynil"
    "app.kubernetes.io/name" = var.component
    "app.kubernetes.io/instance" = var.instance
  }
  removePatch = <<-EOF
    - op: remove
      path: /spec/loadBalancerIP
  EOF
  modifyPatch = <<-EOF
    - op: replace
      path: /spec/loadBalancerIP
      value: "${var.load-balancer.ip}"
    EOF
}

data "kubernetes_secret_v1" "postgresql_password" {
  depends_on = [kubernetes_manifest.gitea_postgresql]
  metadata {
    name = "${var.component}.${var.instance}-${var.component}.credentials.postgresql.acid.zalan.do"
    namespace = var.namespace
  }
}

data "kubernetes_secret_v1" "authentik" {
  metadata {
    name = "authentik"
    namespace = "${var.domain}-auth"
  }
}

data "kustomization_overlay" "data" {
  common_labels = local.common-labels
  namespace = var.namespace
  resources = [for file in fileset(path.module, "*.yaml"): file if ! contains(["index.yaml", "v1_ConfigMap_gitea-themes.yaml"], file)]
  images {
    name = "docker.io/bitnami/memcached"
    new_name = "${var.images.memcached.registry}/${var.images.memcached.repository}"
    new_tag = "${var.images.memcached.tag}"
  }
  patches {
    target {
      kind = "StatefulSet"
      name = "gitea"
    }
    patch = <<-EOF
      apiVersion: apps/v1
      kind: StatefulSet
      metadata:
        name: gitea
      spec:
        replicas: ${var.replicas}
        template:
          spec:
            initContainers:
            - name: init-directories
              image: "${var.images.gitea.registry}/${var.images.gitea.repository}:${var.images.gitea.tag}"
              imagePullPolicy: "${var.images.gitea.pullPolicy}"
            - name: init-app-ini
              image: "${var.images.gitea.registry}/${var.images.gitea.repository}:${var.images.gitea.tag}"
              imagePullPolicy: IfNotPresent
            - name: configure-gitea
              image: "${var.images.gitea.registry}/${var.images.gitea.repository}:${var.images.gitea.tag}"
              imagePullPolicy: IfNotPresent
              env:
              - name: LDAP_USER_SEARCH_BASE
                valueFrom:
                  secretKeyRef:
                    key:  user-search-base
                    name: gitea-ldap
              - name: LDAP_USER_FILTER
                valueFrom:
                  secretKeyRef:
                    key:  user-filter
                    name: gitea-ldap
              - name: LDAP_ADMIN_FILTER
                valueFrom:
                  secretKeyRef:
                    key:  admin-filter
                    name: gitea-ldap
              - name: TZ
                value: ${var.timezone}
            containers:
            - name: gitea
              image: "${var.images.gitea.registry}/${var.images.gitea.repository}:${var.images.gitea.tag}"
              imagePullPolicy: IfNotPresent
              env:
              - name: SSH_LISTEN_PORT
                value: "2222"
              - name: SSH_PORT
                value: "${var.ssh-port}"
              - name: SSH_LOG_LEVEL
                value: "INFO"
              - name: TZ
                value: ${var.timezone}
    EOF
  }
  patches {
    target {
      kind = "Service"
      name = "gitea-ssh"
    }
    patch = <<-EOF
apiVersion: v1
kind: Service
metadata:
  name: gitea-ssh
spec:
  loadBalancerIP: 1.2.3.4
  ports:
  - name: ssh
    port: ${var.ssh-port}
    targetPort: 2222
    protocol: TCP
    EOF
  }
  patches {
    target {
      kind = "Service"
      name = "gitea-ssh"
    }
    patch = var.load-balancer.ip==""?local.removePatch:local.modifyPatch
  }
}
