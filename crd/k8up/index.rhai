const VERSION=config.release;
const DOIT=config.apply;
fn pre_install() {
    if ! global::DOIT {
        return;
    }
    for file in [
        "k8up.io_archives.yaml",
        "k8up.io_backups.yaml",
        "k8up.io_checks.yaml",
        "k8up.io_prebackuppods.yaml",
        "k8up.io_prunes.yaml",
        "k8up.io_restores.yaml",
        "k8up.io_schedules.yaml",
        "k8up.io_snapshots.yaml"
    ] {
        shell(`kubectl apply -f https://raw.githubusercontent.com/k8up-io/k8up/v${global::VERSION}/config/crd/apiextensions.k8s.io/v1/${file}`);
    }
}
