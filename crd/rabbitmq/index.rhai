const VERSION="2.9.0";
const TOPOLOGY="1.14.1";
const SRC=src;
const DEST=dest;
const DOIT=config.apply;
const PURGE=config.purge;
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_bindings.rabbitmq.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_exchanges.rabbitmq.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_federations.rabbitmq.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_operatorpolicies.rabbitmq.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_permissions.rabbitmq.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_policies.rabbitmq.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_queues.rabbitmq.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_rabbitmqclusters.rabbitmq.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_schemareplications.rabbitmq.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_shovels.rabbitmq.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_superstreams.rabbitmq.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_topicpermissions.rabbitmq.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_users.rabbitmq.com.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_vhosts.rabbitmq.com.yaml",
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
    if ! global::PURGE {
        return;
    }
    for file in global::crdFiles {
        shell(`kubectl delete -f ${global::SRC}/${file}`);
    }
}

fn pre_pack() {
    shell(`kubectl kustomize https://github.com/rabbitmq/cluster-operator//config/crd/?ref=v${global::VERSION} > ${global::SRC}/rabbitmq.yaml`);
    shell(`kubectl kustomize https://github.com/rabbitmq/messaging-topology-operator//config/crd/?ref=v${global::TOPOLOGY} > ${global::SRC}/topology.yaml`);
}
