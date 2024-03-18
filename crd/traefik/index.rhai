const VERSION="25.0.0";
const SRC=src;
const DEST=dest;
const DOIT=config.apply;
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_ingressroutes.traefik.containo.us.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_ingressroutes.traefik.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_ingressroutetcps.traefik.containo.us.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_ingressroutetcps.traefik.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_ingressrouteudps.traefik.containo.us.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_ingressrouteudps.traefik.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_middlewares.traefik.containo.us.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_middlewares.traefik.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_middlewaretcps.traefik.containo.us.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_middlewaretcps.traefik.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_serverstransports.traefik.containo.us.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_serverstransports.traefik.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_serverstransporttcps.traefik.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_tlsoptions.traefik.containo.us.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_tlsoptions.traefik.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_tlsstores.traefik.containo.us.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_tlsstores.traefik.io.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_traefikservices.traefik.containo.us.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_traefikservices.traefik.io.yaml",
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
    shell(`kubectl kustomize github.com/traefik/traefik-helm-chart//traefik/crds/?ref=v${global::VERSION} > ${global::SRC}/traefik.yaml`);
}
