const VERSION="2.2.3";
const SRC=src;
const DEST=dest;
const DOIT=config.apply;
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_alerts.notification.toolkit.fluxcd.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_buckets.source.toolkit.fluxcd.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_gitrepositories.source.toolkit.fluxcd.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_helmcharts.source.toolkit.fluxcd.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_helmreleases.helm.toolkit.fluxcd.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_helmrepositories.source.toolkit.fluxcd.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_imagepolicies.image.toolkit.fluxcd.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_imagerepositories.image.toolkit.fluxcd.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_imageupdateautomations.image.toolkit.fluxcd.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_kustomizations.kustomize.toolkit.fluxcd.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_ocirepositories.source.toolkit.fluxcd.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_providers.notification.toolkit.fluxcd.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_receivers.notification.toolkit.fluxcd.io.yaml",
];
fn pre_pack() {
    shell(`kubectl kustomize github.com/fluxcd/flux2//manifests/crds/?ref=v${global::VERSION} > ${global::SRC}/flux.yaml`);
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
