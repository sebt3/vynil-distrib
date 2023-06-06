const VERSION=config.release;
fn pre_install() {
    shell(`kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v${global::VERSION}/cert-manager.crds.yaml`);
}
fn post_install() {
    shell(`kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v${global::VERSION}/cert-manager.crds.yaml`);
}
