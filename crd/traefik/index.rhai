const VERSION=config.release;
const DOIT=config.apply;
fn post_install() {
    if ! global::DOIT {
        return;
    }
    shell(`kubectl apply -k github.com/traefik/traefik-helm-chart//traefik/crds/?ref=v${global::VERSION}`);
}
