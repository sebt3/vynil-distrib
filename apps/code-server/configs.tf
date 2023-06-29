resource "kubectl_manifest" "code-server-config" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: "${var.component}-${var.instance}"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    data:
      config.yml: |
        auth: none
      autostart.sh: |
        #!/bin/bash
        kubectl config set-cluster default --server=https://$${KUBERNETES_SERVICE_HOST}:$${KUBERNETES_SERVICE_PORT} --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt
        kubectl config set-credentials default --token=$(cat /run/secrets/kubernetes.io/serviceaccount/token)
        kubectl config set-context default --cluster=default --user=default
        kubectl config use-context default
        [ -e /home/coder/.bashrc ] || cp /etc/skel/.bashrc /home/coder/.bashrc
  EOF
}
