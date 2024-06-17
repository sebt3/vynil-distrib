resource "kubectl_manifest" "sa" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      labels: ${jsonencode(local.common_labels)}
      name: ${var.instance}-${var.component}
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
EOF
}
resource "kubectl_manifest" "cr" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ${var.namespace}-${var.instance}-${var.component}
      labels: ${jsonencode(local.common_labels)}
    rules:
    - apiGroups:
      - admissionregistration.k8s.io
      resources:
      - mutatingwebhookconfigurations
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - admissionregistration.k8s.io
      resources:
      - validatingwebhookconfigurations
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - apps
      resources:
      - statefulsets
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - apps
      resources:
      - statefulsets/finalizers
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - apps
      resources:
      - statefulsets/scale
      verbs:
      - get
      - update
      - watch
    - apiGroups:
      - apps
      resources:
      - statefulsets/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - batch
      resources:
      - jobs
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - batch
      resources:
      - jobs/finalizers
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - batch
      resources:
      - jobs/status
      verbs:
      - get
    - apiGroups:
      - certificates.k8s.io
      resources:
      - certificatesigningrequests
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - watch
    - apiGroups:
      - certificates.k8s.io
      resources:
      - certificatesigningrequests/approval
      verbs:
      - update
    - apiGroups:
      - certificates.k8s.io
      resources:
      - certificatesigningrequests/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - ''
      resources:
      - configmaps
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - ''
      resources:
      - configmaps/status
      verbs:
      - get
    - apiGroups:
      - ''
      resources:
      - nodes
      verbs:
      - get
      - list
    - apiGroups:
      - ''
      resources:
      - persistentvolumeclaims
      verbs:
      - list
      - update
    - apiGroups:
      - ''
      resources:
      - pods
      verbs:
      - delete
      - deletecollection
      - get
      - list
    - apiGroups:
      - ''
      resources:
      - pods/exec
      verbs:
      - create
    - apiGroups:
      - ''
      resources:
      - pods/log
      verbs:
      - get
    - apiGroups:
      - ''
      resources:
      - secrets
      verbs:
      - create
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - ''
      resources:
      - serviceaccounts
      verbs:
      - create
      - get
      - list
      - watch
    - apiGroups:
      - ''
      resources:
      - services
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - ''
      resources:
      - services/finalizers
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - ''
      resources:
      - services/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - crdb.cockroachlabs.com
      resources:
      - crdbclusters
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - crdb.cockroachlabs.com
      resources:
      - crdbclusters/finalizers
      verbs:
      - update
    - apiGroups:
      - crdb.cockroachlabs.com
      resources:
      - crdbclusters/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - networking.k8s.io
      resources:
      - ingresses
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - networking.k8s.io
      resources:
      - ingresses/finalizers
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - networking.k8s.io
      resources:
      - ingresses/status
      verbs:
      - get
    - apiGroups:
      - policy
      resources:
      - poddisruptionbudgets
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - policy
      resources:
      - poddisruptionbudgets/finalizers
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - policy
      resources:
      - poddisruptionbudgets/status
      verbs:
      - get
    - apiGroups:
      - rbac.authorization.k8s.io
      resources:
      - rolebindings
      verbs:
      - create
      - get
      - list
      - watch
    - apiGroups:
      - rbac.authorization.k8s.io
      resources:
      - roles
      verbs:
      - create
      - get
      - list
      - watch
    - apiGroups:
      - security.openshift.io
      resources:
      - securitycontextconstraints
      verbs:
      - use
EOF
}

resource "kubectl_manifest" "ClusterRoleBinding_cockroach-operator-rolebinding" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: ${var.namespace}-${var.instance}-${var.component}
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

