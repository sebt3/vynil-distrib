
# first loop through resources in ids_prio[0]
resource "kustomization_resource" "pre_no_ns" {
  for_each = data.kustomization_overlay.data_no_ns.ids_prio[0]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_overlay.data_no_ns.manifests[each.value])
    : data.kustomization_overlay.data_no_ns.manifests[each.value]
  )
}

# then loop through resources in ids_prio[1]
# and set an explicit depends_on on kustomization_resource.pre
# wait 2 minutes for any deployment or daemonset to become ready
resource "kustomization_resource" "main_no_ns" {
  for_each = data.kustomization_overlay.data_no_ns.ids_prio[1]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_overlay.data_no_ns.manifests[each.value])
    : data.kustomization_overlay.data_no_ns.manifests[each.value]
  )
  wait = true
  timeouts {
    create = "5m"
    update = "5m"
  }

  depends_on = [kustomization_resource.pre_no_ns]
}

# finally, loop through resources in ids_prio[2]
# and set an explicit depends_on on kustomization_resource.main
resource "kustomization_resource" "post_no_ns" {
  for_each = data.kustomization_overlay.data_no_ns.ids_prio[2]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_overlay.data_no_ns.manifests[each.value])
    : data.kustomization_overlay.data_no_ns.manifests[each.value]
  )

  depends_on = [kustomization_resource.main_no_ns]
}
