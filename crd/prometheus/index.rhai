const VERSION=config.release;
const DOIT=config.apply;
fn pre_install() {
    if ! global::DOIT {
        return;
    }
    for file in [
        "monitoring.coreos.com_alertmanagerconfigs.yaml",
        "monitoring.coreos.com_alertmanagers.yaml",
        "monitoring.coreos.com_prometheusrules.yaml",
        "monitoring.coreos.com_servicemonitors.yaml",
        "monitoring.coreos.com_podmonitors.yaml",
        "monitoring.coreos.com_probes.yaml",
        "monitoring.coreos.com_thanosrulers.yaml"
    ] {
        shell(`kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v${global::VERSION}/example/prometheus-operator-crd/${file}`);
    }
    for file in [
        "monitoring.coreos.com_prometheuses.yaml",
        "monitoring.coreos.com_prometheusagents.yaml"
    ] {
        shell(`kubectl create -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v${global::VERSION}/example/prometheus-operator-crd/${file} || :`);
    }
}

fn post_destroy() {
    if ! global::DOIT {
        return;
    }
    for file in [
        "monitoring.coreos.com_alertmanagerconfigs.yaml",
        "monitoring.coreos.com_alertmanagers.yaml",
        "monitoring.coreos.com_prometheusrules.yaml",
        "monitoring.coreos.com_servicemonitors.yaml",
        "monitoring.coreos.com_podmonitors.yaml",
        "monitoring.coreos.com_probes.yaml",
        "monitoring.coreos.com_thanosrulers.yaml",
        "monitoring.coreos.com_prometheuses.yaml",
        "monitoring.coreos.com_prometheusagents.yaml"
    ] {
        shell(`kubectl delete -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v${global::VERSION}/example/prometheus-operator-crd/${file} || :`);
    }
}
