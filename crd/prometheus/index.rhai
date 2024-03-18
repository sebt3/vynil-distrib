const VERSION="0.71.0";
const SRC=src;
const DEST=dest;
const DOIT=config.apply;
const sourcesDir=`https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v${VERSION}/example/prometheus-operator-crd`;
const sources=[
    "monitoring.coreos.com_alertmanagerconfigs.yaml",
    "monitoring.coreos.com_alertmanagers.yaml",
    "monitoring.coreos.com_prometheusrules.yaml",
    "monitoring.coreos.com_servicemonitors.yaml",
    "monitoring.coreos.com_podmonitors.yaml",
    "monitoring.coreos.com_probes.yaml",
    "monitoring.coreos.com_thanosrulers.yaml",
    "monitoring.coreos.com_prometheuses.yaml",
    "monitoring.coreos.com_prometheusagents.yaml",
];
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_alertmanagerconfigs.monitoring.coreos.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_alertmanagers.monitoring.coreos.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_podmonitors.monitoring.coreos.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_probes.monitoring.coreos.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_prometheusagents.monitoring.coreos.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_prometheuses.monitoring.coreos.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_prometheusrules.monitoring.coreos.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_servicemonitors.monitoring.coreos.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_thanosrulers.monitoring.coreos.com.yaml",
];
fn pre_pack() {
    for file in global::sources {
        shell(`curl -sL ${global::sourcesDir}/${file} > ${global::SRC}/${file}`);
    }
}
fn pre_install() {
    if ! global::DOIT {
        return;
    }
    for file in global::crdFiles {
        shell(`kubectl replace -f ${global::SRC}/${file} || kubectl create -f ${global::SRC}/${file}`);
    }
}
fn post_destroy() {
    if ! global::DOIT {
        return;
    }
    for file in global::crdFiles {
        shell(`kubectl delete -f ${global::SRC}/${file}`);
    }
}
