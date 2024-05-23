resource "kubectl_manifest" "topology" {
  yaml_body  = <<-EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels: ${jsonencode(local.topology_all_labels)}
      name: "${var.instance}-${var.component}-topology"
      namespace: ${var.namespace}
    spec:
      replicas: 1
      selector:
        matchLabels: ${jsonencode(local.topology_labels)}
      template:
        metadata:
          labels: ${jsonencode(local.topology_labels)}
        spec:
          containers:
          - command:
            - /manager
            env:
            - name: OPERATOR_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            image: "${var.images.topology.registry}/${var.images.topology.repository}:${var.images.topology.tag}"
            imagePullPolicy: ${var.images.topology.pull_policy}
            name: manager
            ports:
            - containerPort: 9443
              name: webhook-server
              protocol: TCP
            resources:
              limits:
                cpu: 300m
                memory: 500Mi
              requests:
                cpu: 100m
                memory: 100Mi
            volumeMounts:
            - mountPath: /tmp/k8s-webhook-server/serving-certs
              name: cert
              readOnly: true
          serviceAccountName: ${kubectl_manifest.sa_topology.name}
          terminationGracePeriodSeconds: 10
          volumes:
          - name: cert
            secret:
              defaultMode: 420
              secretName: ${kubectl_manifest.cert.name}
EOF
}

