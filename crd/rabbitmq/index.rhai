const VERSION="2.7.0";
const SRC=src;
const DEST=dest;
const DOIT=config.apply;
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_rabbitmqclusters.rabbitmq.com.yaml",
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
    shell(`kubectl kustomize https://github.com/rabbitmq/cluster-operator//config/crd/?ref=v${global::VERSION} > ${global::SRC}/rabbitmq.yaml`);
}
