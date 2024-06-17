resource "kubectl_manifest" "Job_kyverno-scale-to-zero" {
  force_new = true
  count = 0
  yaml_body  = <<-EOF
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: kyverno-scale-to-zero
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      backoffLimit: 2
      template:
        metadata: null
        spec:
          serviceAccount: kyverno-admission-controller
          restartPolicy: Never
          containers:
          - name: kubectl
            image: ${var.images.kubectl.registry}/${var.images.kubectl.repository}:${var.images.kubectl.tag}
            imagePullPolicy: ${var.images.kubectl.pull_policy}
            command:
            - /bin/bash
            - -c
            - |-
              set -euo pipefail
              kubectl scale -n ${var.namespace} deployment -l app.kubernetes.io/part-of=kyverno --replicas=0
              sleep 30
              kubectl delete validatingwebhookconfiguration -l webhook.kyverno.io/managed-by=kyverno
              kubectl delete mutatingwebhookconfiguration -l webhook.kyverno.io/managed-by=kyverno
            securityContext:
              allowPrivilegeEscalation: false
              capabilities:
                drop:
                - ALL
              privileged: false
              readOnlyRootFilesystem: true
              runAsGroup: 65534
              runAsNonRoot: true
              runAsUser: 65534
              seccompProfile:
                type: RuntimeDefault
EOF
}

resource "kubectl_manifest" "Job_kyverno-clean-reports" {
  force_new = true
  yaml_body  = <<-EOF
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: kyverno-clean-reports
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      backoffLimit: 2
      template:
        metadata: null
        spec:
          serviceAccount: kyverno-admission-controller
          restartPolicy: Never
          containers:
          - name: kubectl
            image: ${var.images.kubectl.registry}/${var.images.kubectl.repository}:${var.images.kubectl.tag}
            imagePullPolicy: ${var.images.kubectl.pull_policy}
            command:
            - /bin/bash
            - -c
            - "set -euo pipefail\nNAMESPACES=$(kubectl get namespaces --no-headers=true | awk '{print $1}')\n\nfor ns in $${NAMESPACES[@]};\ndo\n  COUNT=$(kubectl get policyreports.wgpolicyk8s.io -n $ns --no-headers=true | awk '/pol/{print $1}' | wc -l)\n\n  if [ $COUNT -gt 0 ]; then\n    echo \"deleting $COUNT policyreports in namespace $ns\"\n    kubectl get policyreports.wgpolicyk8s.io -n $ns --no-headers=true | awk '/pol/{print $1}' | xargs kubectl delete -n $ns policyreports.wgpolicyk8s.io\n  else\n    echo \"no policyreports in namespace $ns\"\n  fi\ndone\n\nCOUNT=$(kubectl get clusterpolicyreports.wgpolicyk8s.io --no-headers=true | awk '/pol/{print $1}' | wc -l)\n  \nif [ $COUNT -gt 0 ]; then\n  echo \"deleting $COUNT clusterpolicyreports\"\n  kubectl get clusterpolicyreports.wgpolicyk8s.io --no-headers=true | awk '/pol/{print $1}' | xargs kubectl delete clusterpolicyreports.wgpolicyk8s.io\nelse\n  echo \"no clusterpolicyreports\"\nfi\n"
            securityContext:
              allowPrivilegeEscalation: false
              capabilities:
                drop:
                - ALL
              privileged: false
              readOnlyRootFilesystem: true
              runAsGroup: 65534
              runAsNonRoot: true
              runAsUser: 65534
              seccompProfile:
                type: RuntimeDefault
EOF
}

resource "kubectl_manifest" "Job_kyverno-migrate-resources" {
  force_new = true
  yaml_body  = <<-EOF
    apiVersion: batch/v1
    kind: Job
    metadata:
      name: kyverno-migrate-resources
      namespace: ${var.namespace}
      labels: ${jsonencode(local.common_labels)}
      annotations:
        helm.sh/hook: post-upgrade
        helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded,hook-failed
        helm.sh/hook-weight: '200'
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      backoffLimit: 2
      template:
        metadata: null
        spec:
          serviceAccount: kyverno-migrate-resources
          restartPolicy: Never
          containers:
          - name: kubectl
            image: ${var.images.cli.registry}/${var.images.cli.repository}:${var.images.cli.tag}
            imagePullPolicy: ${var.images.cli.pull_policy}
            args:
            - migrate
            - --resource
            - admissionreports.kyverno.io
            - --resource
            - backgroundscanreports.kyverno.io
            - --resource
            - cleanuppolicies.kyverno.io
            - --resource
            - clusteradmissionreports.kyverno.io
            - --resource
            - clusterbackgroundscanreports.kyverno.io
            - --resource
            - clustercleanuppolicies.kyverno.io
            - --resource
            - clusterpolicies.kyverno.io
            - --resource
            - globalcontextentries.kyverno.io
            - --resource
            - policies.kyverno.io
            - --resource
            - policyexceptions.kyverno.io
            - --resource
            - updaterequests.kyverno.io
            securityContext:
              allowPrivilegeEscalation: false
              capabilities:
                drop:
                - ALL
              privileged: false
              readOnlyRootFilesystem: true
              runAsGroup: 65534
              runAsNonRoot: true
              runAsUser: 65534
              seccompProfile:
                type: RuntimeDefault
EOF
}

