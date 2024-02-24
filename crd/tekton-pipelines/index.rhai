const VERSION="0.57.0";
const SRC=src;
const DEST=dest;
const DOIT=config.apply;
const sourcesDir=`https://storage.googleapis.com/tekton-releases/pipeline/previous/v${VERSION}`;
const sources=[
    "release.yaml",
];
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_clustertasks.tekton.dev.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_customruns.tekton.dev.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_pipelineruns.tekton.dev.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_pipelines.tekton.dev.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_resolutionrequests.resolution.tekton.dev.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_stepactions.tekton.dev.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_taskruns.tekton.dev.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_tasks.tekton.dev.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_verificationpolicies.tekton.dev.yaml",
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
