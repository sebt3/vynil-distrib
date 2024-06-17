const DOIT=config.apply;
const PURGE=config.purge;
const SRC=src;
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_kubeauthenticationconfigurations.kacp.solidite.fr",
];
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
