const VERSION="0.7.0";
const SRC=src;
const DEST=dest;
const DOIT=config.apply;
const PURGE=config.purge;
const hookFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_capsuleconfigurations.capsule.clastix.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_tenants.capsule.clastix.io.yaml",
];
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_capsuleconfigurations.capsule.clastix.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_globaltenantresources.capsule.clastix.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_tenantresources.capsule.clastix.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_tenants.capsule.clastix.io.yaml",
];
fn pre_pack() {
    shell(`kubectl kustomize https://github.com/projectcapsule/capsule//config/crd/?ref=v${global::VERSION} > ${global::SRC}/release.yaml`);
}
fn post_pack() {
    for file in global::hookFiles {
        shell(`sed -i '5i cert-manager.io/inject-ca-from: "{{ operator_namespace }}/{{ operator_cert }}"' ${global::DEST}/${file}`);
        shell(`sed -i 's/namespace: system$/namespace: {{ operator_namespace }}/;s/name: webhook-service/name: {{ operator_service }}/;5s/^/    /' ${global::DEST}/${file}`);
        shell(`mv ${global::DEST}/${file} ${global::DEST}/${file}.hbs`);
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
    if ! global::PURGE {
        return;
    }
    for file in global::crdFiles {
        shell(`kubectl delete -f ${global::SRC}/${file}`);
    }
}
