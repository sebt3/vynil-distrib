resource "kubectl_manifest" "CronJob_kyverno-cleanup-cluster-admission-reports" {
  yaml_body  = <<-EOF
    apiVersion: batch/v1
    kind: CronJob
    metadata:
      name: kyverno-cleanup-cluster-admission-reports
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      schedule: '*/10 * * * *'
      concurrencyPolicy: Forbid
      successfulJobsHistoryLimit: 1
      failedJobsHistoryLimit: 1
      jobTemplate:
        spec:
          backoffLimit: 3
          template:
            metadata: null
            spec:
              serviceAccountName: kyverno-cleanup-jobs
              containers:
              - name: cleanup
                image: ${var.images.kubectl.registry}/${var.images.kubectl.repository}:${var.images.kubectl.tag}
                imagePullPolicy: ${var.images.kubectl.pull_policy}
                command:
                - /bin/bash
                - -c
                - |
                  set -euo pipefail
                  COUNT=$(kubectl get clusteradmissionreports.kyverno.io -A | wc -l)
                  if [ "$COUNT" -gt 10000 ]; then
                    echo "too many reports found ($COUNT), cleaning up..."
                    kubectl delete clusteradmissionreports.kyverno.io -A -l='!audit.kyverno.io/report.aggregate'
                  else
                    echo "($COUNT) reports found, no clean up needed"
                  fi
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
              restartPolicy: OnFailure
EOF
}

resource "kubectl_manifest" "CronJob_kyverno-cleanup-ephemeral-reports" {
  yaml_body  = <<-EOF
    apiVersion: batch/v1
    kind: CronJob
    metadata:
      name: kyverno-cleanup-ephemeral-reports
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      schedule: '*/10 * * * *'
      concurrencyPolicy: Forbid
      successfulJobsHistoryLimit: 1
      failedJobsHistoryLimit: 1
      jobTemplate:
        spec:
          backoffLimit: 3
          template:
            metadata: null
            spec:
              serviceAccountName: kyverno-cleanup-jobs
              containers:
              - name: cleanup
                image: ${var.images.kubectl.registry}/${var.images.kubectl.repository}:${var.images.kubectl.tag}
                imagePullPolicy: ${var.images.kubectl.pull_policy}
                command:
                - /bin/bash
                - -c
                - |
                  set -euo pipefail
                  COUNT=$(kubectl get ephemeralreports.reports.kyverno.io -A | wc -l)
                  if [ "$COUNT" -gt 10000 ]; then
                    echo "too many ephemeralreports found ($COUNT), cleaning up..."
                    kubectl delete ephemeralreports.reports.kyverno.io -A --all
                  else
                    echo "($COUNT) reports found, no clean up needed"
                  fi
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
              restartPolicy: OnFailure
EOF
}

resource "kubectl_manifest" "CronJob_kyverno-cleanup-cluster-ephemeral-reports" {
  yaml_body  = <<-EOF
    apiVersion: batch/v1
    kind: CronJob
    metadata:
      name: kyverno-cleanup-cluster-ephemeral-reports
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      schedule: '*/10 * * * *'
      concurrencyPolicy: Forbid
      successfulJobsHistoryLimit: 1
      failedJobsHistoryLimit: 1
      jobTemplate:
        spec:
          backoffLimit: 3
          template:
            metadata: null
            spec:
              serviceAccountName: kyverno-cleanup-jobs
              containers:
              - name: cleanup
                image: ${var.images.kubectl.registry}/${var.images.kubectl.repository}:${var.images.kubectl.tag}
                imagePullPolicy: ${var.images.kubectl.pull_policy}
                command:
                - /bin/bash
                - -c
                - |
                  set -euo pipefail
                  COUNT=$(kubectl get clusterephemeralreports.reports.kyverno.io -A | wc -l)
                  if [ "$COUNT" -gt 10000 ]; then
                    echo "too many clusterephemeralreports found ($COUNT), cleaning up..."
                    kubectl delete clusterephemeralreports.reports.kyverno.io -A --all
                  else
                    echo "($COUNT) reports found, no clean up needed"
                  fi
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
              restartPolicy: OnFailure
EOF
}

resource "kubectl_manifest" "CronJob_kyverno-cleanup-admission-reports" {
  yaml_body  = <<-EOF
    apiVersion: batch/v1
    kind: CronJob
    metadata:
      name: kyverno-cleanup-admission-reports
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      schedule: '*/10 * * * *'
      concurrencyPolicy: Forbid
      successfulJobsHistoryLimit: 1
      failedJobsHistoryLimit: 1
      jobTemplate:
        spec:
          backoffLimit: 3
          template:
            metadata: null
            spec:
              serviceAccountName: kyverno-cleanup-jobs
              containers:
              - name: cleanup
                image: ${var.images.kubectl.registry}/${var.images.kubectl.repository}:${var.images.kubectl.tag}
                imagePullPolicy: ${var.images.kubectl.pull_policy}
                command:
                - /bin/bash
                - -c
                - |
                  set -euo pipefail
                  COUNT=$(kubectl get admissionreports.kyverno.io -A | wc -l)
                  if [ "$COUNT" -gt 10000 ]; then
                    echo "too many reports found ($COUNT), cleaning up..."
                    kubectl delete admissionreports.kyverno.io -A -l='!audit.kyverno.io/report.aggregate'
                  else
                    echo "($COUNT) reports found, no clean up needed"
                  fi
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
              restartPolicy: OnFailure
EOF
}

resource "kubectl_manifest" "CronJob_kyverno-cleanup-update-requests" {
  yaml_body  = <<-EOF
    apiVersion: batch/v1
    kind: CronJob
    metadata:
      name: kyverno-cleanup-update-requests
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      schedule: '*/10 * * * *'
      concurrencyPolicy: Forbid
      successfulJobsHistoryLimit: 1
      failedJobsHistoryLimit: 1
      jobTemplate:
        spec:
          backoffLimit: 3
          template:
            metadata: null
            spec:
              serviceAccountName: kyverno-cleanup-jobs
              containers:
              - name: cleanup
                image: ${var.images.kubectl.registry}/${var.images.kubectl.repository}:${var.images.kubectl.tag}
                imagePullPolicy: ${var.images.kubectl.pull_policy}
                command:
                - /bin/bash
                - -c
                - |
                  set -euo pipefail
                  COUNT=$(kubectl get updaterequests.kyverno.io -A | wc -l)
                  if [ "$COUNT" -gt 10000 ]; then
                    echo "too many updaterequests found ($COUNT), cleaning up..."
                    kubectl delete updaterequests.kyverno.io --all -n kyverno
                  else
                    echo "($COUNT) reports found, no clean up needed"
                  fi
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
              restartPolicy: OnFailure
EOF
}

