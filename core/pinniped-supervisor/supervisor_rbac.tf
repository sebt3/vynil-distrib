resource "kubectl_manifest" "ServiceAccount_pinniped-supervisor" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: pinniped-supervisor
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
EOF
}

resource "kubectl_manifest" "RoleBinding_pinniped-supervisor-extension-apiserver-authentication-reader" {
  yaml_body  = <<-EOF
    kind: RoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: pinniped-supervisor-extension-apiserver-authentication-reader
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    subjects:
    - kind: ServiceAccount
      name: pinniped-supervisor
      namespace: pinniped-supervisor
    roleRef:
      kind: Role
      name: extension-apiserver-authentication-reader
      apiGroup: rbac.authorization.k8s.io
EOF
}

resource "kubectl_manifest" "ClusterRoleBinding_pinniped-supervisor" {
  yaml_body  = <<-EOF
    kind: ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: pinniped-supervisor
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    subjects:
    - kind: ServiceAccount
      name: pinniped-supervisor
      namespace: pinniped-supervisor
    roleRef:
      kind: ClusterRole
      name: system:auth-delegator
      apiGroup: rbac.authorization.k8s.io
EOF
}

resource "kubectl_manifest" "ClusterRoleBinding_pinniped-supervisor-aggregated-api-server" {
  yaml_body  = <<-EOF
    kind: ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: pinniped-supervisor-aggregated-api-server
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    subjects:
    - kind: ServiceAccount
      name: pinniped-supervisor
      namespace: pinniped-supervisor
    roleRef:
      kind: ClusterRole
      name: pinniped-supervisor-aggregated-api-server
      apiGroup: rbac.authorization.k8s.io
EOF
}

resource "kubectl_manifest" "ClusterRole_pinniped-supervisor-aggregated-api-server" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: pinniped-supervisor-aggregated-api-server
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    rules:
    - apiGroups:
      - ''
      resources:
      - namespaces
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - apiregistration.k8s.io
      resources:
      - apiservices
      verbs:
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - admissionregistration.k8s.io
      resources:
      - validatingwebhookconfigurations
      - mutatingwebhookconfigurations
      - validatingadmissionpolicies
      - validatingadmissionpolicybindings
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - flowcontrol.apiserver.k8s.io
      resources:
      - flowschemas
      - prioritylevelconfigurations
      verbs:
      - get
      - list
      - watch
EOF
}

resource "kubectl_manifest" "RoleBinding_pinniped-supervisor" {
  yaml_body  = <<-EOF
    kind: RoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: pinniped-supervisor
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    subjects:
    - kind: ServiceAccount
      name: pinniped-supervisor
      namespace: pinniped-supervisor
    roleRef:
      kind: Role
      name: pinniped-supervisor
      apiGroup: rbac.authorization.k8s.io
EOF
}

resource "kubectl_manifest" "Role_pinniped-supervisor" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      name: pinniped-supervisor
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    rules:
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
      - delete
    - apiGroups:
      - config.supervisor.pinniped.dev
      resources:
      - federationdomains
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - config.supervisor.pinniped.dev
      resources:
      - federationdomains/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - config.supervisor.pinniped.dev
      resources:
      - oidcclients
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - config.supervisor.pinniped.dev
      resources:
      - oidcclients/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - idp.supervisor.pinniped.dev
      resources:
      - oidcidentityproviders
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - idp.supervisor.pinniped.dev
      resources:
      - oidcidentityproviders/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - idp.supervisor.pinniped.dev
      resources:
      - ldapidentityproviders
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - idp.supervisor.pinniped.dev
      resources:
      - ldapidentityproviders/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - idp.supervisor.pinniped.dev
      resources:
      - activedirectoryidentityproviders
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - idp.supervisor.pinniped.dev
      resources:
      - activedirectoryidentityproviders/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - idp.supervisor.pinniped.dev
      resources:
      - githubidentityproviders
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - idp.supervisor.pinniped.dev
      resources:
      - githubidentityproviders/status
      verbs:
      - get
      - patch
      - update
    - apiGroups:
      - ''
      resources:
      - pods
      verbs:
      - get
    - apiGroups:
      - apps
      resources:
      - replicasets
      - deployments
      verbs:
      - get
    - apiGroups:
      - coordination.k8s.io
      resources:
      - leases
      verbs:
      - create
      - get
      - update
EOF
}

