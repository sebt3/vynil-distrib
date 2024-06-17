resource "kubectl_manifest" "deploy" {
  yaml_body  = <<-EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels: ${jsonencode(local.common_labels)}
      name: ${var.instance}-${var.component}
      namespace: ${var.namespace}
      ownerReferences: ${jsonencode(var.install_owner)}
    spec:
      replicas: 1
      selector:
        matchLabels: ${jsonencode(local.selector)}
      template:
        metadata:
          labels: ${jsonencode(local.selector)}
        spec:
          containers:
          - args:
            - -zap-log-level
            - info
            env:
            - name: RELATED_IMAGE_COCKROACH_v20_1_4
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.1.4
            - name: RELATED_IMAGE_COCKROACH_v20_1_5
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.1.5
            - name: RELATED_IMAGE_COCKROACH_v20_1_8
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.1.8
            - name: RELATED_IMAGE_COCKROACH_v20_1_11
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.1.11
            - name: RELATED_IMAGE_COCKROACH_v20_1_12
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.1.12
            - name: RELATED_IMAGE_COCKROACH_v20_1_13
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.1.13
            - name: RELATED_IMAGE_COCKROACH_v20_1_15
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.1.15
            - name: RELATED_IMAGE_COCKROACH_v20_1_16
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.1.16
            - name: RELATED_IMAGE_COCKROACH_v20_1_17
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.1.17
            - name: RELATED_IMAGE_COCKROACH_v20_2_0
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.2.0
            - name: RELATED_IMAGE_COCKROACH_v20_2_1
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.2.1
            - name: RELATED_IMAGE_COCKROACH_v20_2_2
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.2.2
            - name: RELATED_IMAGE_COCKROACH_v20_2_3
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.2.3
            - name: RELATED_IMAGE_COCKROACH_v20_2_4
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.2.4
            - name: RELATED_IMAGE_COCKROACH_v20_2_5
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.2.5
            - name: RELATED_IMAGE_COCKROACH_v20_2_6
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.2.6
            - name: RELATED_IMAGE_COCKROACH_v20_2_8
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.2.8
            - name: RELATED_IMAGE_COCKROACH_v20_2_9
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.2.9
            - name: RELATED_IMAGE_COCKROACH_v20_2_10
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.2.10
            - name: RELATED_IMAGE_COCKROACH_v20_2_11
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.2.11
            - name: RELATED_IMAGE_COCKROACH_v20_2_12
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.2.12
            - name: RELATED_IMAGE_COCKROACH_v20_2_13
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.2.13
            - name: RELATED_IMAGE_COCKROACH_v20_2_14
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.2.14
            - name: RELATED_IMAGE_COCKROACH_v20_2_15
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.2.15
            - name: RELATED_IMAGE_COCKROACH_v20_2_16
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.2.16
            - name: RELATED_IMAGE_COCKROACH_v20_2_17
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.2.17
            - name: RELATED_IMAGE_COCKROACH_v20_2_18
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.2.18
            - name: RELATED_IMAGE_COCKROACH_v20_2_19
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v20.2.19
            - name: RELATED_IMAGE_COCKROACH_v21_1_0
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.0
            - name: RELATED_IMAGE_COCKROACH_v21_1_1
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.1
            - name: RELATED_IMAGE_COCKROACH_v21_1_2
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.2
            - name: RELATED_IMAGE_COCKROACH_v21_1_3
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.3
            - name: RELATED_IMAGE_COCKROACH_v21_1_4
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.4
            - name: RELATED_IMAGE_COCKROACH_v21_1_5
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.5
            - name: RELATED_IMAGE_COCKROACH_v21_1_6
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.6
            - name: RELATED_IMAGE_COCKROACH_v21_1_7
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.7
            - name: RELATED_IMAGE_COCKROACH_v21_1_9
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.9
            - name: RELATED_IMAGE_COCKROACH_v21_1_10
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.10
            - name: RELATED_IMAGE_COCKROACH_v21_1_11
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.11
            - name: RELATED_IMAGE_COCKROACH_v21_1_12
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.12
            - name: RELATED_IMAGE_COCKROACH_v21_1_13
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.13
            - name: RELATED_IMAGE_COCKROACH_v21_1_14
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.14
            - name: RELATED_IMAGE_COCKROACH_v21_1_15
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.15
            - name: RELATED_IMAGE_COCKROACH_v21_1_16
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.16
            - name: RELATED_IMAGE_COCKROACH_v21_1_17
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.17
            - name: RELATED_IMAGE_COCKROACH_v21_1_18
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.18
            - name: RELATED_IMAGE_COCKROACH_v21_1_19
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.19
            - name: RELATED_IMAGE_COCKROACH_v21_1_20
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.20
            - name: RELATED_IMAGE_COCKROACH_v21_1_21
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.1.21
            - name: RELATED_IMAGE_COCKROACH_v21_2_0
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.2.0
            - name: RELATED_IMAGE_COCKROACH_v21_2_1
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.2.1
            - name: RELATED_IMAGE_COCKROACH_v21_2_2
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.2.2
            - name: RELATED_IMAGE_COCKROACH_v21_2_3
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.2.3
            - name: RELATED_IMAGE_COCKROACH_v21_2_4
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.2.4
            - name: RELATED_IMAGE_COCKROACH_v21_2_5
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.2.5
            - name: RELATED_IMAGE_COCKROACH_v21_2_7
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.2.7
            - name: RELATED_IMAGE_COCKROACH_v21_2_8
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.2.8
            - name: RELATED_IMAGE_COCKROACH_v21_2_9
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.2.9
            - name: RELATED_IMAGE_COCKROACH_v21_2_10
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.2.10
            - name: RELATED_IMAGE_COCKROACH_v21_2_11
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.2.11
            - name: RELATED_IMAGE_COCKROACH_v21_2_12
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.2.12
            - name: RELATED_IMAGE_COCKROACH_v21_2_13
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.2.13
            - name: RELATED_IMAGE_COCKROACH_v21_2_14
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.2.14
            - name: RELATED_IMAGE_COCKROACH_v21_2_15
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.2.15
            - name: RELATED_IMAGE_COCKROACH_v21_2_16
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.2.16
            - name: RELATED_IMAGE_COCKROACH_v21_2_17
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v21.2.17
            - name: RELATED_IMAGE_COCKROACH_v22_1_0
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.1.0
            - name: RELATED_IMAGE_COCKROACH_v22_1_1
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.1.1
            - name: RELATED_IMAGE_COCKROACH_v22_1_2
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.1.2
            - name: RELATED_IMAGE_COCKROACH_v22_1_3
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.1.3
            - name: RELATED_IMAGE_COCKROACH_v22_1_4
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.1.4
            - name: RELATED_IMAGE_COCKROACH_v22_1_5
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.1.5
            - name: RELATED_IMAGE_COCKROACH_v22_1_7
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.1.7
            - name: RELATED_IMAGE_COCKROACH_v22_1_8
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.1.8
            - name: RELATED_IMAGE_COCKROACH_v22_1_10
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.1.10
            - name: RELATED_IMAGE_COCKROACH_v22_1_11
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.1.11
            - name: RELATED_IMAGE_COCKROACH_v22_1_12
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.1.12
            - name: RELATED_IMAGE_COCKROACH_v22_1_13
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.1.13
            - name: RELATED_IMAGE_COCKROACH_v22_1_14
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.1.14
            - name: RELATED_IMAGE_COCKROACH_v22_1_15
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.1.15
            - name: RELATED_IMAGE_COCKROACH_v22_1_16
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.1.16
            - name: RELATED_IMAGE_COCKROACH_v22_1_18
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.1.18
            - name: RELATED_IMAGE_COCKROACH_v22_1_20
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.1.20
            - name: RELATED_IMAGE_COCKROACH_v22_1_22
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.1.22
            - name: RELATED_IMAGE_COCKROACH_v22_2_0
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.2.0
            - name: RELATED_IMAGE_COCKROACH_v22_2_1
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.2.1
            - name: RELATED_IMAGE_COCKROACH_v22_2_2
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.2.2
            - name: RELATED_IMAGE_COCKROACH_v22_2_3
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.2.3
            - name: RELATED_IMAGE_COCKROACH_v22_2_4
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.2.4
            - name: RELATED_IMAGE_COCKROACH_v22_2_5
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.2.5
            - name: RELATED_IMAGE_COCKROACH_v22_2_6
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.2.6
            - name: RELATED_IMAGE_COCKROACH_v22_2_7
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.2.7
            - name: RELATED_IMAGE_COCKROACH_v22_2_8
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.2.8
            - name: RELATED_IMAGE_COCKROACH_v22_2_9
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.2.9
            - name: RELATED_IMAGE_COCKROACH_v22_2_10
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.2.10
            - name: RELATED_IMAGE_COCKROACH_v22_2_12
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.2.12
            - name: RELATED_IMAGE_COCKROACH_v22_2_14
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.2.14
            - name: RELATED_IMAGE_COCKROACH_v22_2_15
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.2.15
            - name: RELATED_IMAGE_COCKROACH_v22_2_16
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.2.16
            - name: RELATED_IMAGE_COCKROACH_v22_2_17
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.2.17
            - name: RELATED_IMAGE_COCKROACH_v22_2_18
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.2.18
            - name: RELATED_IMAGE_COCKROACH_v22_2_19
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v22.2.19
            - name: RELATED_IMAGE_COCKROACH_v23_1_0
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.1.0
            - name: RELATED_IMAGE_COCKROACH_v23_1_1
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.1.1
            - name: RELATED_IMAGE_COCKROACH_v23_1_2
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.1.2
            - name: RELATED_IMAGE_COCKROACH_v23_1_3
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.1.3
            - name: RELATED_IMAGE_COCKROACH_v23_1_4
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.1.4
            - name: RELATED_IMAGE_COCKROACH_v23_1_5
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.1.5
            - name: RELATED_IMAGE_COCKROACH_v23_1_6
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.1.6
            - name: RELATED_IMAGE_COCKROACH_v23_1_7
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.1.7
            - name: RELATED_IMAGE_COCKROACH_v23_1_8
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.1.8
            - name: RELATED_IMAGE_COCKROACH_v23_1_9
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.1.9
            - name: RELATED_IMAGE_COCKROACH_v23_1_10
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.1.10
            - name: RELATED_IMAGE_COCKROACH_v23_1_11
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.1.11
            - name: RELATED_IMAGE_COCKROACH_v23_1_12
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.1.12
            - name: RELATED_IMAGE_COCKROACH_v23_1_13
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.1.13
            - name: RELATED_IMAGE_COCKROACH_v23_1_14
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.1.14
            - name: RELATED_IMAGE_COCKROACH_v23_1_15
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.1.15
            - name: RELATED_IMAGE_COCKROACH_v23_1_16
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.1.16
            - name: RELATED_IMAGE_COCKROACH_v23_1_17
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.1.17
            - name: RELATED_IMAGE_COCKROACH_v23_2_0
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.2.0
            - name: RELATED_IMAGE_COCKROACH_v23_2_1
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.2.1
            - name: RELATED_IMAGE_COCKROACH_v23_2_2
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.2.2
            - name: RELATED_IMAGE_COCKROACH_v23_2_3
              value: ${var.images.cockroach.registry}/${var.images.cockroach.repository}:v23.2.3
            - name: OPERATOR_NAME
              value: cockroachdb
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            image: ${var.images.operator.registry}/${var.images.operator.repository}:${var.images.operator.tag}
            imagePullPolicy: ${var.images.operator.pull_policy}
            name: cockroach-operator
            resources:
              requests:
                cpu: 10m
                memory: 32Mi
          serviceAccountName: ${kubectl_manifest.sa.name}
EOF
}

