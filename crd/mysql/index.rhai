const VERSION=config.release;
const DOIT=config.apply;
fn pre_install() {
    if ! global::DOIT {
        return;
    }
    for file in ["deploy-crds.yaml"] {
        shell(`kubectl create -f https://raw.githubusercontent.com/mysql/mysql-operator/${global::VERSION}/deploy/${file}  || :`);
    }
}
