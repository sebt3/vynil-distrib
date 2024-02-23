const VERSION="1.22.1";
const SRC=src;
const DEST=dest;
const DOIT=config.apply;
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_backups.postgresql.cnpg.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_clusters.postgresql.cnpg.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_poolers.postgresql.cnpg.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_scheduledbackups.postgresql.cnpg.io.yaml"
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
    if ! global::DOIT {
        return;
    }
    for file in global::crdFiles {
        shell(`kubectl delete -f ${global::SRC}/${file}`);
    }
}

fn pre_pack() {
    shell(`curl -sL https://github.com/cloudnative-pg/cloudnative-pg/releases/download/v${global::VERSION}/cnpg-${global::VERSION}.yaml >${global::SRC}/release.yaml`);
}
fn post_pack() {
    for file in [
        "admissionregistration.k8s.io_v1_MutatingWebhookConfiguration_cnpg-mutating-webhook-configuration.yaml",
        "admissionregistration.k8s.io_v1_ValidatingWebhookConfiguration_cnpg-validating-webhook-configuration.yaml",
        "apps_v1_Deployment_cnpg-controller-manager.yaml",
        "rbac.authorization.k8s.io_v1_ClusterRoleBinding_cnpg-manager-rolebinding.yaml",
        "rbac.authorization.k8s.io_v1_ClusterRole_cnpg-manager.yaml",
        "v1_ConfigMap_cnpg-default-monitoring.yaml",
        "v1_Namespace_cnpg-system.yaml",
        "v1_ServiceAccount_cnpg-manager.yaml",
        "v1_Service_cnpg-webhook-service.yaml"
    ] {
        shell(`rm -f ${global::DEST}/${file}`);
    }
}
