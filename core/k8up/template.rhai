const DEST=dest;
fn post_template() {
    save_to_tf(`${global::DEST}/conditions.tf`, "conditions", #{
        have_servicemonitors: have_crd("servicemonitors.monitoring.coreos.com"),
        have_prometheusrules: have_crd("prometheusrules.monitoring.coreos.com")
    });
}
