const VERSION=config.release;
fn pre_install() {
    shell(`kubectl apply -k https://github.com/rabbitmq/cluster-operator//config/crd/?ref=v${global::VERSION}`);
}
