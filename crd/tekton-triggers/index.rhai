const VERSION="0.26.1";
const SRC=src;
const DEST=dest;
const DOIT=config.apply;
const sourcesDir=`https://storage.googleapis.com/tekton-releases/triggers/previous/v${VERSION}`;
const sources=[
    "release.yaml",
    "interceptors.yaml"
];
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_clusterinterceptors.triggers.tekton.dev.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_clustertriggerbindings.triggers.tekton.dev.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_eventlisteners.triggers.tekton.dev.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_interceptors.triggers.tekton.dev.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_triggerbindings.triggers.tekton.dev.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_triggers.triggers.tekton.dev.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_triggertemplates.triggers.tekton.dev.yaml",
];
fn pre_pack() {
    for file in global::sources {
        shell(`curl -sL ${global::sourcesDir}/${file} > ${global::SRC}/${file}`);
    }
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
