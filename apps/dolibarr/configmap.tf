data "kubernetes_ingress_v1" "authentik" {
  metadata {
    name = "authentik"
    namespace = "${var.domain}-auth"
  }
}
locals {
  authentik-metadata-url="${data.kubernetes_ingress_v1.authentik.spec[0].rule[0].host}/api/v3/providers/saml/${authentik_provider_saml.dolibarr.id}/metadata/?download"
  module-list = [
      "user",
      "ldap",
      "syslog"
    ]
  json-config = {
    groups = [ for index, g in local.sorted-groups: {
        name  = g.name
        admin = contains([for k,v in g:k], "admin")?g.admin:false
        users = data.authentik_group.readed_groups[index].users_obj
    }]
    parameters = merge(var.parameters, {
      LDAP_FIELD_FULLNAME="sAMAccountName"
      LDAP_FIELD_LOGIN_SAMBA="sAMAccountName"
      LDAP_FIELD_MAIL="mail"
      LDAP_FIELD_NAME="sn"
      LDAP_GROUP_FIELD_DESCRIPTION="sAMAccountName"
      LDAP_GROUP_FIELD_FULLNAME="cn"
      LDAP_GROUP_FIELD_GROUPID="gidNumber"
      LDAP_GROUP_FIELD_GROUPMEMBERS="member"
      LDAP_GROUP_OBJECT_CLASS="group"
      LDAP_KEY_GROUPS="cn"
      LDAP_KEY_USERS="cn"
      LDAP_PASSWORD_HASH_TYPE="md5"
      LDAP_SERVER_HOST="ak-outpost-ldap.${var.domain}-auth.svc"
      LDAP_SERVER_PORT="389"
      LDAP_SERVER_PROTOCOLVERSION="3"
      LDAP_SERVER_TYPE="openldap"
      LDAP_SERVER_DN="${local.base-dn}"
      LDAP_SERVER_USE_TLS="0"
      LDAP_SYNCHRO_ACTIVE="2"
      LDAP_USER_OBJECT_CLASS="person"
      LDAP_USER_DN=local.base-user-dn
      LDAP_GROUP_DN=local.base-group-dn
      LDAP_GROUP_FILTER="&(&(objectClass=groupOfNames)(|${join("",[for g in local.sorted-groups: format("(cn=%s)",g.name)])}))"
      LDAP_ADMIN_DN="cn=${var.instance}-${var.component}-ldapsearch,${local.base-user-dn}"
      LDAP_FILTER_CONNECTION="&(&(objectClass=inetOrgPerson)(|${join("",[for g in local.sorted-groups: format("(memberof=cn=%s,%s)",g.name,local.base-group-dn)])}))"
      SAMLCONNECTOR_CREATE_UNEXISTING_USER="1"
      SAMLCONNECTOR_MAPPING_USER_EMAIL="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
      SAMLCONNECTOR_MAPPING_USER_FIRSTNAME="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
      SAMLCONNECTOR_MAPPING_USER_LASTNAME="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
      SAMLCONNECTOR_UPDATE_USER_EVERYTIME="1"
      SAMLCONNECTOR_DISABLE_IDP_DISCONNECTION="1"
      SAMLCONNECTOR_IDP_DISPLAY_BUTTON="1"
      SAMLCONNECTOR_IDP_METADATA_SOURCE="url"
      SAMLCONNECTOR_MANAGE_MULTIPLE_IDP="0"
      SAMLCONNECTOR_SP_CERT_PATH="/var/saml/tls.crt"
      SAMLCONNECTOR_SP_PRIV_KEY_PATH="/var/saml/tls.key"
      SAMLCONNECTOR_IDP_METADATA_URL=local.authentik-metadata-url
      SAMLCONNECTOR_IDP_METADATA_XML_PATH=local.authentik-metadata-url
      MAIN_MODULE_SAMLCONNECTOR="1"
      MAIN_MODULE_SAMLCONNECTOR_CSS="[\"\\/samlconnector\\/css\\/samlconnector.css.php\"]"
      MAIN_MODULE_SAMLCONNECTOR_HOOKS="[\"mainloginpage\",\"logout\",\"samlconnectorsetup\"]"
      MAIN_MODULE_SAMLCONNECTOR_JS="[\"\\/samlconnector\\/js\\/samlconnector.js.php\"]"
      MAIN_MODULE_SAMLCONNECTOR_LOGIN="1"
      MAIN_MODULE_SAMLCONNECTOR_MODULEFOREXTERNAL="1"
      MAIN_MODULE_SAMLCONNECTOR_SUBSTITUTIONS="1"
      MAIN_MODULE_SAMLCONNECTOR_TRIGGERS="1"
      SYSLOG_LEVEL="${var.log-level}"
      SYSLOG_FILE="/var/logs/dolibarr.log"
      SYSLOG_HANDLERS="[\"mod_syslog_file\"]"
    })
    modules=join(",",[for i in concat(var.modules, local.module-list): format("MAIN_MODULE_%s",upper(i))])
  }
}

resource "kubectl_manifest" "config-json" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: "${var.instance}-json"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    data:
      "docker-php-ext-redis.ini": |-
        extension = redis.so
        session.save_handler = redis
        session.save_path = "tcp://${var.instance}-${var.component}-redis.${var.namespace}.svc:6379/?prefix=SESSION_${var.component}_${var.instance}:"
      "vynil-configurator.sh": |-
        #!/bin/ash
        pgsqlRun() { PGPASSWORD="$${DOLI_DB_PASSWORD:="dolibarr"}" psql -h "$${DOLI_DB_HOST:="postgres"}" -p "$${DOLI_DB_PORT}" -U "$${DOLI_DB_USER}" -w "$DOLI_DB_NAME" "$@"; }
        setDBconf() { pgsqlRun -c "insert into llx_const(entity, name, type, value, visible) VALUES (1, '$1', 'chaine', '$2', 0) ON CONFLICT(entity, name) DO UPDATE SET value='$2';"; }
        createUser() { pgsqlRun -c "INSERT INTO llx_user(entity, admin, employee, fk_establishment, datec, login, lastname, email, statut, fk_barcode_type, nb_holiday) VALUES (1, 0, 1, 0, NOW(), '$1', '$2', '$3', 1, 0, 0) ON CONFLICT(entity, login) DO UPDATE SET admin=0;"; }
        createAdmin() { pgsqlRun -c "INSERT INTO llx_user(entity, admin, employee, fk_establishment, datec, login, lastname, email, statut, fk_barcode_type, nb_holiday) VALUES (1, 1, 0, 0, NOW(), '$1', '$2', '$3', 1, 0, 0) ON CONFLICT(entity, login) DO UPDATE SET admin=1;"; }
        createGroup() { pgsqlRun -c "INSERT INTO llx_usergroup(entity, nom, datec) VALUES (1, '$1', NOW()) ON CONFLICT(entity, nom) DO NOTHING;"; }
        setGroupPerm() { pgsqlRun -c "insert into llx_usergroup_rights(fk_id,fk_usergroup,entity) select d.id as fk_id, g.rowid as fk_usergroup, 1 as entity from llx_rights_def d, llx_usergroup g where d.id is not null and d.module<>'user' and g.nom='$1' ON CONFLICT(fk_id,fk_usergroup,entity) DO NOTHING;"; }
        setGroupUser() { pgsqlRun -c "insert into llx_usergroup_user(entity, fk_user, fk_usergroup) select 1, u.rowid, g.rowid from llx_usergroup g, llx_user u where g.nom='$1' and u.login='$2' ON CONFLICT(entity, fk_user, fk_usergroup) DO NOTHING;"; }
        configquery() { jq -r "$1" </etc/config/config.json; }
        installMod() { cd /var/www/htdocs/install;php upgrade2.php 0.0.0 0.0.0 "$@"; }
        groupq() { configquery ".groups[$1].$2"; }
        userq() { configquery ".groups[$1].users[$2].$3"; }
        dolEncrypt() {
        { php <<ENDphp
        <?php
        require_once "/app/htdocs/core/lib/security.lib.php";
        print_r(dolEncrypt("$1"));
        ENDphp
        } |tail -1
        }
        # Set parameters
        pcnt=$(configquery ".parameters|keys|length")
        for i in $(seq 0 $(( $pcnt - 1)) );do
            k=$(configquery ".parameters|keys[$i]")
            v=$(configquery ".parameters.$k")
            setDBconf "$k" "$v"
        done
        setDBconf LDAP_ADMIN_PASS "$(dolEncrypt $${DOLI_LDAP_ADMIN_PASS})"
        setDBconf SAMLCONNECTOR_MAPPING_USER_SEARCH_KEY "$(dolEncrypt SAMLCONNECTOR_MAPPING_USER_LASTNAME)"
        rm -f /var/documents/install.lock
        installMod $(configquery ".modules")
        touch /var/documents/install.lock
        chmod 400 /var/documents/install.lock
        # Create groups and users
        gcnt=$(configquery ".groups | length")
        for i in $(seq 0 $(( $gcnt - 1)) );do
            gname=$(groupq $i name)
            echo ' *** '"Creating group: $${gname}"
            createGroup "$${gname}"
            admin=$(groupq $i admin)
            if [[ $${admin} != "true" ]];then
                setGroupPerm "$${gname}"
            fi
            ucnt=$(groupq $i "users | length")
            for j in $(seq 0 $(( $ucnt - 1)) );do
                email=$(userq $i $j email)
                name=$(userq $i $j name)
                username=$(userq $i $j username)
                if [[ $${admin} == "true" ]];then
                    echo ' *** '"Creating admin: $${name}"
                    createAdmin "$${username}" "$${name}" "$${email}"
                else
                    echo ' *** '"Creating user: $${name}"
                    createUser "$${username}" "$${name}" "$${email}"
                fi
                setGroupUser "$${gname}" "$${username}"
            done
        done
        >/var/logs/dolibarr.log
      "config.json": |-
        ${jsonencode(local.json-config)}
  EOF
}

resource "kubectl_manifest" "config" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: "${var.instance}"
      namespace: "${var.namespace}"
      labels: ${jsonencode(local.common-labels)}
    data:
      DOLI_DB_HOST: "${var.instance}-${var.component}.${var.namespace}.svc"
      DOLI_DB_USER: "${var.component}"
      DOLI_DB_NAME: "${var.component}"
      DOLI_DB_PORT: "5432"
      DOLI_DB_TYPE: "pgsql"
      DOLI_ADMIN_LOGIN: "admin_${var.instance}"
      DOLI_MODULES: "modSociete,modBlockedLog,modSamlConnector,modLdap"
      DOLI_AUTH: "dolibarr"
      DOLI_URL_ROOT: "https://${var.sub-domain}.${var.domain-name}"
      DOLI_LDAP_PORT: "389"
      DOLI_LDAP_VERSION: "3"
      DOLI_LDAP_SERVERTYPE: "openldap"
      DOLI_LDAP_LOGIN_ATTRIBUTE: "sAMAccountName"
      DOLI_LDAP_FILTER: "(&(|${join("",[for g in local.sorted-groups: format("(memberof=cn=%s,%s)",g.name,local.base-group-dn)])})(|(uid=%1%)(mail=%1%)))"
      DOLI_LDAP_ADMIN_LOGIN: "cn=${var.instance}-${var.component}-ldapsearch,${local.base-user-dn}"
      DOLI_LDAP_DN: "${local.base-dn}"
      DOLI_LDAP_HOST: "ak-outpost-ldap.${var.domain}-auth.svc"
  EOF
}
