const SRC=src;
const DOIT=config.apply;
const PURGE=config.purge;
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_hierarchicalresourcequotas.hnc.x-k8s.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_hierarchyconfigurations.hnc.x-k8s.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_hncconfigurations.hnc.x-k8s.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_subnamespaceanchors.hnc.x-k8s.io.yaml",
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
