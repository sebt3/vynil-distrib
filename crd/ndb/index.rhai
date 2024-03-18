const VERSION="8.2.0-1.2.0";
const DEST=dest;
fn post_pack() {
    shell(`curl -sL https://raw.githubusercontent.com/mysql/mysql-ndb-operator/release-${global::VERSION}/deploy/charts/ndb-operator/crds/mysql.oracle.com_ndbclusters.yaml >${global::DEST}/mysql.oracle.com_ndbclusters.yaml`);
}

const DOIT=config.apply;
fn pre_install() {
    if ! global::DOIT {
        return;
    }
    for file in [
        "mysql.oracle.com_ndbclusters.yaml",
    ] {
        shell(`kubectl apply -f ${global::SRC}/${file}`);
    }
}


