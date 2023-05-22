const VERSION=config.release;
fn pre_install() {
    shell(`kubectl apply -f https://raw.githubusercontent.com/OT-CONTAINER-KIT/helm-charts/redis-operator-${global::VERSION}/charts/redis-operator/crds/redis.yaml`);
    shell(`kubectl apply -f https://raw.githubusercontent.com/OT-CONTAINER-KIT/helm-charts/redis-operator-${global::VERSION}/charts/redis-operator/crds/redis-sentinel.yaml`);
    shell(`kubectl apply -f https://raw.githubusercontent.com/OT-CONTAINER-KIT/helm-charts/redis-operator-${global::VERSION}/charts/redis-operator/crds/redis-replication.yaml`);
    shell(`kubectl apply -f https://raw.githubusercontent.com/OT-CONTAINER-KIT/helm-charts/redis-operator-${global::VERSION}/charts/redis-operator/crds/redis-cluster.yaml`);
}
