const VERSION="0.93.0";
const SRC=src;
const DEST=dest;
const DOIT=config.apply;
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_instrumentations.opentelemetry.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_opampbridges.opentelemetry.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_opentelemetrycollectors.opentelemetry.io.yaml",
];
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

fn pre_pack() {
    shell(`kubectl kustomize https://github.com/open-telemetry/opentelemetry-operator//config/crd/?ref=v${global::VERSION} > ${global::SRC}/otel.yaml`);
}
