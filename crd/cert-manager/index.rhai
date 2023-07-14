const VERSION=config.release;
const DOIT=config.apply;
fn pre_install() {
    if ! global::DOIT {
        return;
    }
    shell(`kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v${global::VERSION}/cert-manager.crds.yaml`);
}
