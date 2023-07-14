const VERSION=config.release;
const DOIT=config.apply;
fn pre_install() {
    if ! global::DOIT {
        return;
    }
    for file in ["mongodbcommunity.mongodb.com_mongodbcommunity.yaml"] {
        shell(`kubectl apply -f https://raw.githubusercontent.com/mongodb/mongodb-kubernetes-operator/v${global::VERSION}/config/crd/bases/${file}`);
    }
}
