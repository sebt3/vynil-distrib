const VERSION="0.15.9";
const SRC=src;
const DEST=dest;
const DOIT=config.apply;
const sourcesDir=`https://raw.githubusercontent.com/OT-CONTAINER-KIT/helm-charts/redis-operator-${VERSION}/charts/redis-operator/crds`;
const sources=[
    "redis.yaml",
    "redis-sentinel.yaml",
    "redis-replication.yaml",
    "redis-cluster.yaml"
];
const crdFiles=[
    "apiextensions.k8s.io_v1_CustomResourceDefinition_redisclusters.redis.redis.opstreelabs.in.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_redis.redis.redis.opstreelabs.in.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_redisreplications.redis.redis.opstreelabs.in.yaml",
    "apiextensions.k8s.io_v1_CustomResourceDefinition_redissentinels.redis.redis.opstreelabs.in.yaml",
];
fn pre_pack() {
    for file in global::sources {
        shell(`curl -sL ${global::sourcesDir}/${file} > ${global::SRC}/${file}`);
    }
}
fn post_pack() {
    for file in global::crdFiles {
        shell(`sed -i 's/namespace: redis-operator$/namespace: {{ target_namespace }}/' ${global::DEST}/${file}`);
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
