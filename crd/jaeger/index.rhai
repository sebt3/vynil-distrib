const VERSION=config.release;
const DOIT=config.apply;
fn pre_install() {
    if ! global::DOIT {
        return;
    }
    shell(`kubectl apply -k https://github.com/jaegertracing/jaeger-operator//config/crd/?ref=v${global::VERSION}`);
}
