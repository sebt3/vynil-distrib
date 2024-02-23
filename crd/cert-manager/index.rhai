const VERSION="1.14.2";
const SRC=src;
const DEST=dest;
const DOIT=config.apply;
const sourcesDir=`https://github.com/cert-manager/cert-manager/releases/download/v${VERSION}`;
const sources=[
    "cert-manager.crds.yaml",
];
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_certificaterequests.cert-manager.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_certificates.cert-manager.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_challenges.acme.cert-manager.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_clusterissuers.cert-manager.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_issuers.cert-manager.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_orders.acme.cert-manager.io.yaml",
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
