const VERSION="8.4.0-1.4.0";
const SRC=src;
fn pre_pack() {
    shell(`curl -sL https://raw.githubusercontent.com/mysql/mysql-ndb-operator/release-${global::VERSION}/deploy/charts/ndb-operator/crds/mysql.oracle.com_ndbclusters.yaml >${global::SRC}/mysql.oracle.com_ndbclusters.yaml`);
}

const DOIT=config.apply;
fn pre_install() {
    if ! global::DOIT {
        return;
    }
    for file in [
        "apiextensions.k8s.io_v1_CustomResourceDefinition_ndbclusters.mysql.oracle.com.yaml",
    ] {
        shell(`kubectl apply -f ${global::SRC}/${file}`);
    }
}
