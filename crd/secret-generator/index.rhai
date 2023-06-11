const VERSION=config.release;
const DOIT=config.apply;
fn pre_install() {
    if ! global::DOIT {
        return;
    }
    for file in [
        "secretgenerator.mittwald.de_basicauths_crd.yaml",
        "secretgenerator.mittwald.de_sshkeypairs_crd.yaml",
        "secretgenerator.mittwald.de_stringsecrets_crd.yaml"
    ] {
        shell(`kubectl apply -f https://raw.githubusercontent.com/mittwald/kubernetes-secret-generator/v${global::VERSION}/deploy/crds/${file}`);
    }
}
