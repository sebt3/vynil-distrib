const VERSION=config.release;
const DOIT=config.apply;
fn pre_install() {
    if ! global::DOIT {
        return;
    }
    for file in ["crds.yaml"] {
        shell(`kubectl create -f https://raw.githubusercontent.com/mariadb-operator/mariadb-operator/v${global::VERSION}/deploy/crds/${file}  || :`);
    }
}
