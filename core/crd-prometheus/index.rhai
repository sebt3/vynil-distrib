const VERSION=config.release;
fn pre_install() {
    for file in [
        "monitoring.coreos.com_alertmanagerconfigs.yaml",
        "monitoring.coreos.com_alertmanagers.yaml",
        "monitoring.coreos.com_prometheusrules.yaml",
        "monitoring.coreos.com_servicemonitors.yaml",
        "monitoring.coreos.com_podmonitors.yaml",
        "monitoring.coreos.com_probes.yaml",
        "monitoring.coreos.com_prometheusagents.yaml",
        "monitoring.coreos.com_prometheuses.yaml",
        "monitoring.coreos.com_thanosrulers.yaml"
    ] {
        shell(`kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v${global::VERSION}/example/prometheus-operator-crd/${file}`);
    }
}
