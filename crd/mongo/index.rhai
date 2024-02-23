const VERSION="0.9.0";
const SRC=src;
const DEST=dest;
const DOIT=config.apply;
const sourcesDir=`https://raw.githubusercontent.com/mongodb/mongodb-kubernetes-operator/v${VERSION}/config/crd/bases`;
const sources=[
    "mongodbcommunity.mongodb.com_mongodbcommunity.yaml",
];
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_mongodbcommunity.mongodbcommunity.mongodb.com.yaml",
];
fn pre_pack() {
    for file in global::sources {
        shell(`curl -sL ${global::sourcesDir}/${file} > ${global::SRC}/${file}`);
    }
}
fn pre_install() {
    if ! global::DOIT {
        return;
    }
    for file in global::crdFiles {
        shell(`kubectl replace -f ${global::SRC}/${file} || kubectl create -f ${global::SRC}/${file}`);
    }
}
fn post_destroy() {
    if ! global::DOIT {
        return;
    }
    for file in global::crdFiles {
        shell(`kubectl delete -f ${global::SRC}/${file}`);
    }
}
