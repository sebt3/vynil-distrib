const DOIT=config.apply;
const PURGE=config.purge;
const SRC=src;
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_gatewayclasses.gateway.networking.k8s.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_gateways.gateway.networking.k8s.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_grpcroutes.gateway.networking.k8s.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_httproutes.gateway.networking.k8s.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_referencegrants.gateway.networking.k8s.io.yaml",
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
