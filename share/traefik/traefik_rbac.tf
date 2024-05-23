resource "kubectl_manifest" "sa" {
  yaml_body  = <<-EOF
    kind: ServiceAccount
    apiVersion: v1
    metadata:
      name: "${var.instance}-${var.component}"
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common-labels)}
EOF
}

resource "kubectl_manifest" "cr" {
  yaml_body  = <<-EOF
    kind: ClusterRole
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: "${var.namespace}-${var.instance}-${var.component}"
      labels: ${jsonencode(local.common_labels)}
    rules:
    - apiGroups:
      - extensions
      - networking.k8s.io
      resources:
      - ingressclasses
      - ingresses
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - ''
      resources:
      - services
      - endpoints
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - ''
      resources:
      - secrets
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - extensions
      - networking.k8s.io
      resources:
      - ingresses/status
      verbs:
      - update
    - apiGroups:
      - traefik.io
      resources:
      - ingressroutes
      - ingressroutetcps
      - ingressrouteudps
      - middlewares
      - middlewaretcps
      - tlsoptions
      - tlsstores
      - traefikservices
      - serverstransports
      - serverstransporttcps
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - ''
      resources:
      - namespaces
      verbs:
      - list
      - watch
    - apiGroups:
      - gateway.networking.k8s.io
      resources:
      - gatewayclasses
      - gateways
      - httproutes
      - referencegrants
      - tcproutes
      - tlsroutes
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - gateway.networking.k8s.io
      resources:
      - gatewayclasses/status
      - gateways/status
      - httproutes/status
      - tcproutes/status
      - tlsroutes/status
      verbs:
      - update
EOF
}

resource "kubectl_manifest" "crb" {
  yaml_body  = <<-EOF
    kind: ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: ${kubectl_manifest.cr.name}
      labels: ${jsonencode(local.common_labels)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: ${kubectl_manifest.cr.name}
    subjects:
    - kind: ServiceAccount
      name: ${kubectl_manifest.sa.name}
      namespace: ${var.namespace}
EOF
}

