const VERSION="1.20.1";
const SRC=src;
const DEST=dest;
const DOIT=config.apply;
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_canaryconfigs.fission.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_environments.fission.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_functions.fission.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_httptriggers.fission.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_kuberneteswatchtriggers.fission.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_messagequeuetriggers.fission.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_packages.fission.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_timetriggers.fission.io.yaml",
];
fn pre_pack() {
    shell(`kubectl kustomize github.com/fission/fission//crds/v1/?ref=v${global::VERSION} > ${global::SRC}/fission.yaml`);
}
fn post_pack() {
    shell(`for i in $(ls -1 "${global::DEST}"|awk '/yaml$/&&!/^index/&&!/apiextensions/');do rm -f "${global::DEST}/$i";done`);
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
