const VERSION=config.release;
const DEST=src;
fn pre_pack() {
    shell(`kubectl kustomize https://github.com/rabbitmq/cluster-operator//config/manager/?ref=${global::VERSION} >${global::DEST}/manager.yaml`);
    shell(`kubectl kustomize https://github.com/rabbitmq/cluster-operator//config/rbac/?ref=${global::VERSION} >${global::DEST}/rbac.yaml`);
}
fn pre_install() {
    shell(`kubectl apply -k https://github.com/rabbitmq/cluster-operator//config/crd/?ref=v${global::VERSION}`);
}
