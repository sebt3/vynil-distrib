const VERSION="2.7.2";
const SRC=src;
const DEST=dest;
const DOIT=config.apply;
const sourcesDir=`https://raw.githubusercontent.com/k8up-io/k8up/v${VERSION}/config/crd/apiextensions.k8s.io/v1`;
const sources=[
    "k8up.io_archives.yaml",
    "k8up.io_backups.yaml",
    "k8up.io_checks.yaml",
    "k8up.io_prebackuppods.yaml",
    "k8up.io_prunes.yaml",
    "k8up.io_restores.yaml",
    "k8up.io_schedules.yaml",
    "k8up.io_snapshots.yaml"
];
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_archives.k8up.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_backups.k8up.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_checks.k8up.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_prebackuppods.k8up.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_prunes.k8up.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_restores.k8up.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_schedules.k8up.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_snapshots.k8up.io.yaml",
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
