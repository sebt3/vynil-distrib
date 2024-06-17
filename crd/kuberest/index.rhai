const VERSION="2.7.2";
const SRC=src;
const DEST=dest;
const DOIT=config.apply;
const PURGE=config.purge;
const sources=`github.com/sebt3/kuberest//deploy/crd`;
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_restendpoints.kuberest.solidite.fr.yaml",
];
fn pre_pack() {
    shell(`kubectl kustomize ${global::sources} > ${global::SRC}/kuberest.yaml`);
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
    if ! global::PURGE {
        return;
    }
    for file in global::crdFiles {
        shell(`kubectl delete -f ${global::SRC}/${file}`);
    }
}
