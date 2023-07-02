locals {
  begin-core = <<-EOF
    .:53 {
        errors {
            consolidate 5m ".* i/o timeout$" warning
            consolidate 30s "^Failed to .+"
        }
        health {
            lameduck 5s
        }
        ready
  EOF
  end-core = <<-EOF
    }
  EOF
  soa-ns = <<-EOF
    @           IN  SOA  ${var.sub-domain}.${var.domain-name}. ${var.domain-name}. (
                        ${formatdate("YYYYMMDDhh",timestamp())} ; Serial
                        4H         ; Refresh
                        1H         ; Retry
                        7D         ; Expire
                        4H )       ; Negative Cache TTL
    @    IN NS   ${var.sub-domain}.${var.domain-name}.
  EOF
  files = merge({
    "Corefile" = join("", concat([local.begin-core],[for z in var.zones: format("file /etc/coredns/%s.db %s", z.name,z.name)],[local.end-core]))
  },[for z in var.zones: {
    "${z.name}" = join("\n", concat([
      "$TTL 60",
      "$ORIGIN ${z.name}.",
      local.soa-ns
    ],
    [for k,v in z.hosts: format("%s IN A %s", k, v)],
    [for k,v in z.hosts6: format("%s IN AAAA %s", k, v)],
    [for k,v in z.alias: format("%s IN CNAME %s", k, v)],
    z.wildcard!=""?[format("*.%s. IN A %s", z.name, z.wildcard)]:[],
    z.wildcard6!=""?[format("*.%s. IN AAAA %s", z.namz, z.wildcard6)]:[],
    ))
  }]...)
}

resource "kubectl_manifest" "coredns-config" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: "${var.component}-${var.instance}"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    data: ${jsonencode(local.files)}
  EOF
}
