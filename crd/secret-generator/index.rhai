const VERSION="3.4.0";
const SRC=src;
const DEST=dest;
const DOIT=config.apply;
const sourcesDir=`https://raw.githubusercontent.com/mittwald/kubernetes-secret-generator/v${VERSION}/deploy/crds`;
const sources=[
    "secretgenerator.mittwald.de_basicauths_crd.yaml",
    "secretgenerator.mittwald.de_sshkeypairs_crd.yaml",
    "secretgenerator.mittwald.de_stringsecrets_crd.yaml"
];
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_basicauths.secretgenerator.mittwald.de.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_sshkeypairs.secretgenerator.mittwald.de.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_stringsecrets.secretgenerator.mittwald.de.yaml",
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
