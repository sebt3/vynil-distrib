const DEST=dest;
fn post_template() {
    save_to_tf(`${global::DEST}/conditions.tf`, "conditions", #{
        have_gateway: have_crd("gatewayclasses.gateway.networking.k8s.io") && have_crd("gateways.gateway.networking.k8s.io"),
    });
}
