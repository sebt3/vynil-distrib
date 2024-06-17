resource "kubectl_manifest" "ConfigMap_kyverno" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: kyverno
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    data:
      enableDefaultRegistryMutation: 'true'
      defaultRegistry: docker.io
      generateSuccessEvents: 'false'
      excludeGroups: system:nodes
      resourceFilters: '[*/*,${var.namespace},*] [Event,*,*] [*/*,kube-system,*] [*/*,kube-public,*] [*/*,kube-node-lease,*] [Node,*,*] [Node/*,*,*] [APIService,*,*] [APIService/*,*,*] [TokenReview,*,*] [SubjectAccessReview,*,*] [SelfSubjectAccessReview,*,*] [Binding,*,*] [Pod/binding,*,*] [ReplicaSet,*,*] [ReplicaSet/*,*,*] [AdmissionReport,*,*] [AdmissionReport/*,*,*] [ClusterAdmissionReport,*,*] [ClusterAdmissionReport/*,*,*] [BackgroundScanReport,*,*] [BackgroundScanReport/*,*,*] [ClusterBackgroundScanReport,*,*] [ClusterBackgroundScanReport/*,*,*] [ClusterRole,*,kyverno:admission-controller] [ClusterRole,*,kyverno:admission-controller:core] [ClusterRole,*,kyverno:admission-controller:additional] [ClusterRole,*,kyverno:background-controller] [ClusterRole,*,kyverno:background-controller:core] [ClusterRole,*,kyverno:background-controller:additional] [ClusterRole,*,kyverno:cleanup-controller] [ClusterRole,*,kyverno:cleanup-controller:core] [ClusterRole,*,kyverno:cleanup-controller:additional] [ClusterRole,*,kyverno:reports-controller] [ClusterRole,*,kyverno:reports-controller:core] [ClusterRole,*,kyverno:reports-controller:additional] [ClusterRoleBinding,*,kyverno:admission-controller] [ClusterRoleBinding,*,kyverno:background-controller] [ClusterRoleBinding,*,kyverno:cleanup-controller] [ClusterRoleBinding,*,kyverno:reports-controller] [ServiceAccount,${var.namespace},kyverno-admission-controller] [ServiceAccount/*,${var.namespace},kyverno-admission-controller] [ServiceAccount,${var.namespace},kyverno-background-controller] [ServiceAccount/*,${var.namespace},kyverno-background-controller] [ServiceAccount,${var.namespace},kyverno-cleanup-controller] [ServiceAccount/*,${var.namespace},kyverno-cleanup-controller] [ServiceAccount,${var.namespace},kyverno-reports-controller] [ServiceAccount/*,${var.namespace},kyverno-reports-controller] [Role,${var.namespace},kyverno:admission-controller] [Role,${var.namespace},kyverno:background-controller] [Role,${var.namespace},kyverno:cleanup-controller] [Role,${var.namespace},kyverno:reports-controller] [RoleBinding,${var.namespace},kyverno:admission-controller] [RoleBinding,${var.namespace},kyverno:background-controller] [RoleBinding,${var.namespace},kyverno:cleanup-controller] [RoleBinding,${var.namespace},kyverno:reports-controller] [ConfigMap,${var.namespace},kyverno] [ConfigMap,${var.namespace},kyverno-metrics] [Deployment,${var.namespace},kyverno-admission-controller] [Deployment/*,${var.namespace},kyverno-admission-controller] [Deployment,${var.namespace},kyverno-background-controller] [Deployment/*,${var.namespace},kyverno-background-controller] [Deployment,${var.namespace},kyverno-cleanup-controller] [Deployment/*,${var.namespace},kyverno-cleanup-controller] [Deployment,${var.namespace},kyverno-reports-controller] [Deployment/*,${var.namespace},kyverno-reports-controller] [Pod,${var.namespace},kyverno-admission-controller-*] [Pod/*,${var.namespace},kyverno-admission-controller-*] [Pod,${var.namespace},kyverno-background-controller-*] [Pod/*,${var.namespace},kyverno-background-controller-*] [Pod,${var.namespace},kyverno-cleanup-controller-*] [Pod/*,${var.namespace},kyverno-cleanup-controller-*] [Pod,${var.namespace},kyverno-reports-controller-*] [Pod/*,${var.namespace},kyverno-reports-controller-*] [Job,${var.namespace},kyverno-hook-pre-delete] [Job/*,${var.namespace},kyverno-hook-pre-delete] [NetworkPolicy,${var.namespace},kyverno-admission-controller] [NetworkPolicy/*,${var.namespace},kyverno-admission-controller] [NetworkPolicy,${var.namespace},kyverno-background-controller] [NetworkPolicy/*,${var.namespace},kyverno-background-controller] [NetworkPolicy,${var.namespace},kyverno-cleanup-controller] [NetworkPolicy/*,${var.namespace},kyverno-cleanup-controller] [NetworkPolicy,${var.namespace},kyverno-reports-controller] [NetworkPolicy/*,${var.namespace},kyverno-reports-controller] [PodDisruptionBudget,${var.namespace},kyverno-admission-controller] [PodDisruptionBudget/*,${var.namespace},kyverno-admission-controller] [PodDisruptionBudget,${var.namespace},kyverno-background-controller] [PodDisruptionBudget/*,${var.namespace},kyverno-background-controller] [PodDisruptionBudget,${var.namespace},kyverno-cleanup-controller] [PodDisruptionBudget/*,${var.namespace},kyverno-cleanup-controller] [PodDisruptionBudget,${var.namespace},kyverno-reports-controller] [PodDisruptionBudget/*,${var.namespace},kyverno-reports-controller] [Service,${var.namespace},kyverno-svc] [Service/*,${var.namespace},kyverno-svc] [Service,${var.namespace},kyverno-svc-metrics] [Service/*,${var.namespace},kyverno-svc-metrics] [Service,${var.namespace},kyverno-background-controller-metrics] [Service/*,${var.namespace},kyverno-background-controller-metrics] [Service,${var.namespace},kyverno-cleanup-controller] [Service/*,${var.namespace},kyverno-cleanup-controller] [Service,${var.namespace},kyverno-cleanup-controller-metrics] [Service/*,${var.namespace},kyverno-cleanup-controller-metrics] [Service,${var.namespace},kyverno-reports-controller-metrics] [Service/*,${var.namespace},kyverno-reports-controller-metrics] [ServiceMonitor,${var.namespace},kyverno-admission-controller] [ServiceMonitor,${var.namespace},kyverno-background-controller] [ServiceMonitor,${var.namespace},kyverno-cleanup-controller] [ServiceMonitor,${var.namespace},kyverno-reports-controller] [Secret,${var.namespace},kyverno-svc.${var.namespace}.svc.*] [Secret,${var.namespace},kyverno-cleanup-controller.${var.namespace}.svc.*]'
      webhooks: '[{"namespaceSelector":{"matchExpressions":[{"key":"kubernetes.io/metadata.name","operator":"NotIn","values":["kube-system"]},{"key":"kubernetes.io/metadata.name","operator":"NotIn","values":["${var.namespace}"]}],"matchLabels":null}}]'
      webhookAnnotations: '{"admissions.enforcer/disabled":"true"}'
EOF
}

resource "kubectl_manifest" "ConfigMap_kyverno-metrics" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: kyverno-metrics
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    data:
      namespaces: '{"exclude":[],"include":[]}'
      bucketBoundaries: 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10, 15, 20, 25, 30
EOF
}

