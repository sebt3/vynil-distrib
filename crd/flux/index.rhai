const VERSION=config.release;
const DOIT=config.apply;
fn pre_install() {
    if ! global::DOIT {
        return;
    }
    shell(`kubectl apply -k github.com/fluxcd/flux2//manifests/crds/?ref=v${global::VERSION}`);
}
