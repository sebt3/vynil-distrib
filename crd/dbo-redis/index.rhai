const VERSION=config.release;
fn pre_install() {
    for file in [
        "redis.yaml",
        "redis-sentinel.yaml",
        "redis-replication.yaml",
        "redis-cluster.yaml"
    ] {
        shell(`kubectl apply -f https://raw.githubusercontent.com/OT-CONTAINER-KIT/helm-charts/redis-operator-${global::VERSION}/charts/redis-operator/crds/${file}`);
    }
}
