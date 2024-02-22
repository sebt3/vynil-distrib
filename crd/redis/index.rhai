const VERSION=config.release;
const DOIT=config.apply;
fn pre_install() {
    if ! global::DOIT {
        return;
    }
    for file in [
        "redis.yaml",
        "redis-sentinel.yaml",
        "redis-replication.yaml",
        "redis-cluster.yaml"
    ] {
        shell(`kubectl replace -f https://raw.githubusercontent.com/OT-CONTAINER-KIT/helm-charts/redis-operator-${global::VERSION}/charts/redis-operator/crds/${file} || kubectl create -f https://raw.githubusercontent.com/OT-CONTAINER-KIT/helm-charts/redis-operator-${global::VERSION}/charts/redis-operator/crds/${file}`);
    }
}
