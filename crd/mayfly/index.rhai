const VERSION="0.1.6";
const SRC=src;
const DEST=dest;
const DOIT=config.apply;
const sourcesDir=`https://github.com/NCCloud/mayfly/raw/v${VERSION}/deploy/crds`;
const sources=[
    "cloud.namecheap.com_scheduledresources.yaml",
];
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_scheduledresources.cloud.namecheap.com.yaml",
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
