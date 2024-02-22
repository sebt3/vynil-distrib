const VERSION=config.release;
const DOIT=config.apply;
fn pre_install() {
    if ! global::DOIT {
        return;
    }
    for file in [
        `https://github.com/NCCloud/mayfly/raw/v${global::VERSION}/deploy/crds/cloud.namecheap.com_scheduledresources.yaml`,
    ] {
        shell(`kubectl replace -f ${file} || kubectl create -f ${file}`);
    }
}
