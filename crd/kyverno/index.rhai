const SRC=src;
const DOIT=config.apply;
const PURGE=config.purge;
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_admissionreports.kyverno.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_backgroundscanreports.kyverno.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_cleanuppolicies.kyverno.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_clusteradmissionreports.kyverno.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_clusterbackgroundscanreports.kyverno.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_clustercleanuppolicies.kyverno.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_clusterephemeralreports.reports.kyverno.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_clusterpolicies.kyverno.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_clusterpolicyreports.wgpolicyk8s.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_ephemeralreports.reports.kyverno.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_globalcontextentries.kyverno.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_policies.kyverno.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_policyexceptions.kyverno.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_policyreports.wgpolicyk8s.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_updaterequests.kyverno.io.yaml",
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
