
const NS=config.namespace;
const SRC=src;
const DEST=dest;
fn pre_pack() {
    shell("helm repo add gitea-charts https://dl.gitea.io/charts/");
    shell(`helm template gitea gitea-charts/gitea --namespace=vynil-ci --values values.yml >${global::SRC}/chart.yaml`);
}
fn post_pack() {
    shell(`rm -f ${global::DEST}/v1_Pod_gitea-test-connection.yaml`);
    shell(`rm -f ${global::DEST}/v1_Secret_gitea-inline-config.yaml`);
    let regex = "'\\\\\\${\\(LDAP_[A-Z_]*\\)}'";
    let final = "\\\"\\${\\1}\\\"";
    shell(`sed -i "s/${regex}/${final}/g" ${global::DEST}/v1_Secret_gitea-init.yaml`);
}
fn pre_install() {
    shell(`kubectl create -n ${global::NS} -f ${global::SRC}/v1_ConfigMap_gitea-themes.yaml || :`);
}
