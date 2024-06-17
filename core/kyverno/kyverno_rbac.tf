resource "kubectl_manifest" "ServiceAccount_kyverno-reports-controller" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: kyverno-reports-controller
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
EOF
}

resource "kubectl_manifest" "ServiceAccount_kyverno-background-controller" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: kyverno-background-controller
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
EOF
}

resource "kubectl_manifest" "ServiceAccount_kyverno-cleanup-controller" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: kyverno-cleanup-controller
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
EOF
}

resource "kubectl_manifest" "ServiceAccount_kyverno-migrate-resources" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: kyverno-migrate-resources
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      annotations:
        helm.sh/hook: post-upgrade
        helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
        helm.sh/hook-weight: '100'
      ownerReferences: ${jsonencode(var.install_owner)}
EOF
}

resource "kubectl_manifest" "ServiceAccount_kyverno-admission-controller" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: kyverno-admission-controller
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
EOF
}

resource "kubectl_manifest" "ServiceAccount_kyverno-cleanup-jobs" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: kyverno-cleanup-jobs
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
EOF
}

resource "kubectl_manifest" "ClusterRoleBinding_kyverno_cleanup-controller" {
  yaml_body  = <<-EOF
    kind: ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: kyverno:cleanup-controller
      labels: ${jsonencode(local.common_labels)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: kyverno:cleanup-controller
    subjects:
    - kind: ServiceAccount
      name: kyverno-cleanup-controller
      namespace: ${var.namespace}
EOF
}

resource "kubectl_manifest" "ClusterRole_kyverno_admission-controller" {
  ignore_fields = ["rules"]
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kyverno:admission-controller
      labels: ${jsonencode(local.admission_all_labels)}
    aggregationRule:
      clusterRoleSelectors:
      - matchLabels: ${jsonencode(local.admission_labels)}
EOF
}

resource "kubectl_manifest" "RoleBinding_kyverno_cleanup-controller" {
  yaml_body  = <<-EOF
    kind: RoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: kyverno:cleanup-controller
      labels: ${jsonencode(local.common_labels)}
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: kyverno:cleanup-controller
    subjects:
    - kind: ServiceAccount
      name: kyverno-cleanup-controller
      namespace: ${var.namespace}
EOF
}

resource "kubectl_manifest" "RoleBinding_kyverno_reports-controller" {
  yaml_body  = <<-EOF
    kind: RoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: kyverno:reports-controller
      labels: ${jsonencode(local.common_labels)}
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: kyverno:reports-controller
    subjects:
    - kind: ServiceAccount
      name: kyverno-reports-controller
      namespace: ${var.namespace}
EOF
}

resource "kubectl_manifest" "Role_kyverno_cleanup-controller" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      name: kyverno:cleanup-controller
      labels: ${jsonencode(local.common_labels)}
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
    rules:
    - apiGroups:
      - ''
      resources:
      - secrets
      verbs:
      - create
    - apiGroups:
      - ''
      resources:
      - secrets
      verbs:
      - delete
      - get
      - list
      - update
      - watch
      resourceNames:
      - kyverno-cleanup-controller.${var.namespace}.svc.kyverno-tls-ca
      - kyverno-cleanup-controller.${var.namespace}.svc.kyverno-tls-pair
    - apiGroups:
      - ''
      resources:
      - configmaps
      verbs:
      - get
      - list
      - watch
      resourceNames:
      - kyverno
      - kyverno-metrics
    - apiGroups:
      - coordination.k8s.io
      resources:
      - leases
      verbs:
      - create
    - apiGroups:
      - coordination.k8s.io
      resources:
      - leases
      verbs:
      - delete
      - get
      - patch
      - update
      resourceNames:
      - kyverno-cleanup-controller
EOF
}

resource "kubectl_manifest" "ClusterRole_kyverno_rbac_view_policyreports" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kyverno:rbac:view:policyreports
      labels: ${jsonencode(local.common_labels)}
    rules:
    - apiGroups:
      - wgpolicyk8s.io
      resources:
      - policyreports
      - clusterpolicyreports
      verbs:
      - get
      - list
      - watch
EOF
}

resource "kubectl_manifest" "ClusterRoleBinding_kyverno_admission-controller" {
  yaml_body  = <<-EOF
    kind: ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: kyverno:admission-controller
      labels: ${jsonencode(local.common_labels)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: kyverno:admission-controller
    subjects:
    - kind: ServiceAccount
      name: kyverno-admission-controller
      namespace: ${var.namespace}
EOF
}

resource "kubectl_manifest" "ClusterRoleBinding_kyverno_cleanup-jobs" {
  yaml_body  = <<-EOF
    kind: ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: kyverno:cleanup-jobs
      labels: ${jsonencode(local.common_labels)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: kyverno:cleanup-jobs
    subjects:
    - kind: ServiceAccount
      name: kyverno-cleanup-jobs
      namespace: ${var.namespace}
EOF
}

resource "kubectl_manifest" "ClusterRole_kyverno_rbac_view_updaterequests" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kyverno:rbac:view:updaterequests
      labels: ${jsonencode(local.common_labels)}
    rules:
    - apiGroups:
      - kyverno.io
      resources:
      - updaterequests
      verbs:
      - get
      - list
      - watch
EOF
}

resource "kubectl_manifest" "RoleBinding_kyverno_admission-controller" {
  yaml_body  = <<-EOF
    kind: RoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: kyverno:admission-controller
      namespace: ${var.namespace}
      labels: ${jsonencode(local.admission_all_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: kyverno:admission-controller
    subjects:
    - kind: ServiceAccount
      name: kyverno-admission-controller
      namespace: ${var.namespace}
EOF
}

resource "kubectl_manifest" "Role_kyverno_reports-controller" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      name: kyverno:reports-controller
      labels: ${jsonencode(local.common_labels)}
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
    rules:
    - apiGroups:
      - ''
      resources:
      - configmaps
      verbs:
      - get
      - list
      - watch
      resourceNames:
      - kyverno
      - kyverno-metrics
    - apiGroups:
      - coordination.k8s.io
      resources:
      - leases
      verbs:
      - create
    - apiGroups:
      - coordination.k8s.io
      resources:
      - leases
      verbs:
      - delete
      - get
      - patch
      - update
      resourceNames:
      - kyverno-reports-controller
EOF
}

resource "kubectl_manifest" "Role_kyverno_background-controller" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      name: kyverno:background-controller
      labels: ${jsonencode(local.common_labels)}
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
    rules:
    - apiGroups:
      - ''
      resources:
      - configmaps
      verbs:
      - get
      - list
      - watch
      resourceNames:
      - kyverno
      - kyverno-metrics
    - apiGroups:
      - coordination.k8s.io
      resources:
      - leases
      verbs:
      - create
    - apiGroups:
      - coordination.k8s.io
      resources:
      - leases
      verbs:
      - delete
      - get
      - patch
      - update
      resourceNames:
      - kyverno-background-controller
    - apiGroups:
      - ''
      resources:
      - secrets
      verbs:
      - get
      - list
      - watch
EOF
}

resource "kubectl_manifest" "ClusterRole_kyverno_rbac_admin_policyreports" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kyverno:rbac:admin:policyreports
      labels: ${jsonencode(local.common_labels)}
    rules:
    - apiGroups:
      - wgpolicyk8s.io
      resources:
      - policyreports
      - clusterpolicyreports
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
EOF
}

resource "kubectl_manifest" "ClusterRoleBinding_kyverno_background-controller" {
  yaml_body  = <<-EOF
    kind: ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: kyverno:background-controller
      labels: ${jsonencode(local.common_labels)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: kyverno:background-controller
    subjects:
    - kind: ServiceAccount
      name: kyverno-background-controller
      namespace: ${var.namespace}
EOF
}

resource "kubectl_manifest" "RoleBinding_kyverno_background-controller" {
  yaml_body  = <<-EOF
    kind: RoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: kyverno:background-controller
      labels: ${jsonencode(local.common_labels)}
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: kyverno:background-controller
    subjects:
    - kind: ServiceAccount
      name: kyverno-background-controller
      namespace: ${var.namespace}
EOF
}

resource "kubectl_manifest" "ClusterRole_kyverno_cleanup-jobs" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kyverno:cleanup-jobs
      labels: ${jsonencode(local.common_labels)}
    rules:
    - apiGroups:
      - kyverno.io
      resources:
      - admissionreports
      - clusteradmissionreports
      - updaterequests
      verbs:
      - list
      - deletecollection
      - delete
    - apiGroups:
      - reports.kyverno.io
      resources:
      - ephemeralreports
      - clusterephemeralreports
      verbs:
      - list
      - deletecollection
      - delete
EOF
}

resource "kubectl_manifest" "ClusterRole_kyverno_reports-controller" {
  ignore_fields = ["rules"]
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kyverno:reports-controller
      labels: ${jsonencode(local.reports_all_labels)}
    aggregationRule:
      clusterRoleSelectors:
      - matchLabels: ${jsonencode(local.admission_labels)}
EOF
}

resource "kubectl_manifest" "ClusterRole_kyverno_background-controller" {
  ignore_fields = ["rules"]
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kyverno:background-controller
      labels: ${jsonencode(local.background_all_labels)}
    aggregationRule:
      clusterRoleSelectors:
      - matchLabels: ${jsonencode(local.background_labels)}
EOF
}

resource "kubectl_manifest" "ClusterRole_kyverno_rbac_view_reports" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kyverno:rbac:view:reports
      labels: ${jsonencode(local.common_labels)}
    rules:
    - apiGroups:
      - kyverno.io
      resources:
      - admissionreports
      - clusteradmissionreports
      - backgroundscanreports
      - clusterbackgroundscanreports
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - reports.kyverno.io
      resources:
      - ephemeralreports
      - clusterephemeralreports
      verbs:
      - get
      - list
      - watch
EOF
}

resource "kubectl_manifest" "ClusterRole_kyverno_migrate-resources" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kyverno:migrate-resources
      labels: ${jsonencode(local.common_labels)}
      annotations:
        helm.sh/hook: post-upgrade
        helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded,hook-failed
        helm.sh/hook-weight: '100'
    rules:
    - apiGroups:
      - kyverno.io
      resources:
      - '*'
      verbs:
      - get
      - list
      - update
    - apiGroups:
      - apiextensions.k8s.io
      resources:
      - customresourcedefinitions
      verbs:
      - get
    - apiGroups:
      - apiextensions.k8s.io
      resources:
      - customresourcedefinitions/status
      verbs:
      - update
EOF
}

resource "kubectl_manifest" "ClusterRole_kyverno_rbac_view_policies" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kyverno:rbac:view:policies
      labels: ${jsonencode(local.common_labels)}
    rules:
    - apiGroups:
      - kyverno.io
      resources:
      - cleanuppolicies
      - clustercleanuppolicies
      - policies
      - clusterpolicies
      verbs:
      - get
      - list
      - watch
EOF
}

resource "kubectl_manifest" "ClusterRole_kyverno_rbac_admin_policies" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kyverno:rbac:admin:policies
      labels: ${jsonencode(local.common_labels)}
    rules:
    - apiGroups:
      - kyverno.io
      resources:
      - cleanuppolicies
      - clustercleanuppolicies
      - policies
      - clusterpolicies
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
EOF
}

resource "kubectl_manifest" "ClusterRole_kyverno_admission-controller_core" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kyverno:admission-controller:core
      labels: ${jsonencode(local.admission_all_labels)}
    rules:
    - apiGroups:
      - apiextensions.k8s.io
      resources:
      - customresourcedefinitions
      verbs:
      - get
    - apiGroups:
      - admissionregistration.k8s.io
      resources:
      - mutatingwebhookconfigurations
      - validatingwebhookconfigurations
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
      - deletecollection
    - apiGroups:
      - rbac.authorization.k8s.io
      resources:
      - roles
      - clusterroles
      - rolebindings
      - clusterrolebindings
      verbs:
      - list
      - watch
    - apiGroups:
      - kyverno.io
      resources:
      - policies
      - policies/status
      - clusterpolicies
      - clusterpolicies/status
      - updaterequests
      - updaterequests/status
      - globalcontextentries
      - globalcontextentries/status
      - admissionreports
      - clusteradmissionreports
      - backgroundscanreports
      - clusterbackgroundscanreports
      - policyexceptions
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
      - deletecollection
    - apiGroups:
      - reports.kyverno.io
      resources:
      - ephemeralreports
      - clusterephemeralreports
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
      - deletecollection
    - apiGroups:
      - wgpolicyk8s.io
      resources:
      - policyreports
      - policyreports/status
      - clusterpolicyreports
      - clusterpolicyreports/status
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
      - deletecollection
    - apiGroups:
      - ''
      - events.k8s.io
      resources:
      - events
      verbs:
      - create
      - update
      - patch
    - apiGroups:
      - authorization.k8s.io
      resources:
      - subjectaccessreviews
      verbs:
      - create
    - apiGroups:
      - ''
      resources:
      - configmaps
      - namespaces
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - coordination.k8s.io
      resources:
      - leases
      verbs:
      - create
      - update
      - patch
      - get
      - list
      - watch
    - apiGroups:
      - '*'
      resources:
      - '*'
      verbs:
      - get
      - list
      - watch
EOF
}

resource "kubectl_manifest" "ClusterRole_kyverno_cleanup-controller_core" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kyverno:cleanup-controller:core
      labels: ${jsonencode(local.cleanup_all_labels)}
    rules:
    - apiGroups:
      - apiextensions.k8s.io
      resources:
      - customresourcedefinitions
      verbs:
      - get
    - apiGroups:
      - admissionregistration.k8s.io
      resources:
      - validatingwebhookconfigurations
      verbs:
      - create
      - delete
      - get
      - list
      - update
      - watch
    - apiGroups:
      - ''
      resources:
      - namespaces
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - kyverno.io
      resources:
      - clustercleanuppolicies
      - cleanuppolicies
      verbs:
      - list
      - watch
    - apiGroups:
      - kyverno.io
      resources:
      - globalcontextentries
      - globalcontextentries/status
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
      - deletecollection
    - apiGroups:
      - kyverno.io
      resources:
      - clustercleanuppolicies/status
      - cleanuppolicies/status
      verbs:
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
      - events.k8s.io
      resources:
      - events
      verbs:
      - create
      - patch
      - update
    - apiGroups:
      - authorization.k8s.io
      resources:
      - subjectaccessreviews
      verbs:
      - create
EOF
}

resource "kubectl_manifest" "ClusterRole_kyverno_cleanup-controller" {
  ignore_fields = ["rules"]
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kyverno:cleanup-controller
      labels: ${jsonencode(local.cleanup_all_labels)}
    aggregationRule:
      clusterRoleSelectors:
      - matchLabels: ${jsonencode(local.cleanup_labels)}
EOF
}

resource "kubectl_manifest" "ClusterRoleBinding_kyverno_migrate-resources" {
  yaml_body  = <<-EOF
    kind: ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: kyverno:migrate-resources
      labels: ${jsonencode(local.common_labels)}
      annotations:
        helm.sh/hook: post-upgrade
        helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded,hook-failed
        helm.sh/hook-weight: '100'
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: kyverno:migrate-resources
    subjects:
    - kind: ServiceAccount
      name: kyverno-migrate-resources
      namespace: ${var.namespace}
EOF
}

resource "kubectl_manifest" "ClusterRole_kyverno_background-controller_core" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kyverno:background-controller:core
      labels: ${jsonencode(local.background_all_labels)}
    rules:
    - apiGroups:
      - apiextensions.k8s.io
      resources:
      - customresourcedefinitions
      verbs:
      - get
    - apiGroups:
      - kyverno.io
      resources:
      - policies
      - clusterpolicies
      - policyexceptions
      - updaterequests
      - updaterequests/status
      - globalcontextentries
      - globalcontextentries/status
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
      - deletecollection
    - apiGroups:
      - ''
      resources:
      - namespaces
      - configmaps
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - ''
      - events.k8s.io
      resources:
      - events
      verbs:
      - create
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - '*'
      resources:
      - '*'
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - networking.k8s.io
      resources:
      - ingresses
      - ingressclasses
      - networkpolicies
      verbs:
      - create
      - update
      - patch
      - delete
    - apiGroups:
      - rbac.authorization.k8s.io
      resources:
      - rolebindings
      - roles
      verbs:
      - create
      - update
      - patch
      - delete
    - apiGroups:
      - ''
      resources:
      - configmaps
      - secrets
      - resourcequotas
      - limitranges
      verbs:
      - create
      - update
      - patch
      - delete
EOF
}

resource "kubectl_manifest" "ClusterRole_kyverno_rbac_admin_reports" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kyverno:rbac:admin:reports
      labels: ${jsonencode(local.common_labels)}
    rules:
    - apiGroups:
      - kyverno.io
      resources:
      - admissionreports
      - clusteradmissionreports
      - backgroundscanreports
      - clusterbackgroundscanreports
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
    - apiGroups:
      - reports.kyverno.io
      resources:
      - ephemeralreports
      - clusterephemeralreports
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
EOF
}

resource "kubectl_manifest" "ClusterRole_kyverno_rbac_admin_updaterequests" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kyverno:rbac:admin:updaterequests
      labels: ${jsonencode(local.common_labels)}
    rules:
    - apiGroups:
      - kyverno.io
      resources:
      - updaterequests
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
EOF
}

resource "kubectl_manifest" "ClusterRole_kyverno_reports-controller_core" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kyverno:reports-controller:core
      labels: ${jsonencode(local.reports_all_labels)}
    rules:
    - apiGroups:
      - apiextensions.k8s.io
      resources:
      - customresourcedefinitions
      verbs:
      - get
    - apiGroups:
      - ''
      resources:
      - secrets
      - configmaps
      - namespaces
      verbs:
      - get
      - list
      - watch
    - apiGroups:
      - kyverno.io
      resources:
      - globalcontextentries
      - globalcontextentries/status
      - admissionreports
      - clusteradmissionreports
      - backgroundscanreports
      - clusterbackgroundscanreports
      - policyexceptions
      - policies
      - clusterpolicies
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
      - deletecollection
    - apiGroups:
      - reports.kyverno.io
      resources:
      - ephemeralreports
      - clusterephemeralreports
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
      - deletecollection
    - apiGroups:
      - wgpolicyk8s.io
      resources:
      - policyreports
      - policyreports/status
      - clusterpolicyreports
      - clusterpolicyreports/status
      verbs:
      - create
      - delete
      - get
      - list
      - patch
      - update
      - watch
      - deletecollection
    - apiGroups:
      - ''
      - events.k8s.io
      resources:
      - events
      verbs:
      - create
      - patch
    - apiGroups:
      - '*'
      resources:
      - '*'
      verbs:
      - get
      - list
      - watch
EOF
}

resource "kubectl_manifest" "Role_kyverno_admission-controller" {
  yaml_body  = <<-EOF
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      name: kyverno:admission-controller
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
    rules:
    - apiGroups:
      - ''
      resources:
      - secrets
      verbs:
      - get
      - list
      - watch
      - create
      - update
      - delete
    - apiGroups:
      - ''
      resources:
      - configmaps
      verbs:
      - get
      - list
      - watch
      resourceNames:
      - kyverno
      - kyverno-metrics
    - apiGroups:
      - coordination.k8s.io
      resources:
      - leases
      verbs:
      - create
      - delete
      - get
      - patch
      - update
    - apiGroups:
      - apps
      resources:
      - deployments
      - deployments/scale
      verbs:
      - get
      - list
      - watch
      - patch
      - update
EOF
}

resource "kubectl_manifest" "ClusterRoleBinding_kyverno_reports-controller" {
  yaml_body  = <<-EOF
    kind: ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: kyverno:reports-controller
      labels: ${jsonencode(local.common_labels)}
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: kyverno:reports-controller
    subjects:
    - kind: ServiceAccount
      name: kyverno-reports-controller
      namespace: ${var.namespace}
EOF
}

