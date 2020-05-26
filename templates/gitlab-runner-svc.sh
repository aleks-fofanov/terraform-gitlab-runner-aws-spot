#!/bin/bash
# chkconfig: 1356 98 10
# description: A service that manages runner registration with Gitlab on startup/shutdown
# processname: gitlab-runner-svc
#              /etc/rc.d/init.d/gitlab-runner-svc

# Author - Aleksandr Fofanov

# Links:
# https://linuxexplore.com/2014/03/19/use-of-subsystem-lock-files-in-init-script/

lockfile=/var/lock/subsys/gitlab-runner-svc
KMS_KEY_CLAUSE=$([[ "${auth_token_ssm_param_kms_key}" == "" ]] && echo "" || echo "--key-id ${auth_token_ssm_param_kms_key}")

start() {
    if [[ ! -f $lockfile ]]; then
        gitlab-runner unregister --all-runners -c ${gitlab_runner_config_path}

        if [[ "${registration_token_ssm_param}" != "" ]]; then
            REGISTRATION_TOKEN=$(aws ssm get-parameter --with-decryption --name ${registration_token_ssm_param} --region="${region}" | jq -r '.Parameter.Value')
        else
            REGISTRATION_TOKEN="${registration_token}"
        fi

        # Why we need docker-volumes clauses:
        # https://gitlab.com/gitlab-org/gitlab-runner/issues/4735

        logger "Registering runner ${runner_name}"
        gitlab-runner register \
          --non-interactive \
          --config ${gitlab_runner_config_path} \
          --template-config ${template_config_path} \
          --url "${gitlab_url}" \
          --registration-token "$REGISTRATION_TOKEN" \
          --name "${runner_name}" \
          --executor "docker+machine" \
          --docker-image "${image}" \
          --tag-list "${tags}" \
          --locked="${locked}" \
          --run-untagged="${run_untagged}" \
          ${docker_volumes_clauses}

        AUTH_TOKEN=$(grep -oP 'token = "\K[^"]+' ${gitlab_runner_config_path})
        aws ssm put-parameter \
            --overwrite \
            --type SecureString  \
            --name "${auth_token_ssm_param_name}" \
            --value="$AUTH_TOKEN" \
            --region="${region}" \
            $KMS_KEY_CLAUSE 2>&1 >/dev/null | logger

        touch $lockfile
    fi
}

stop() {
    logger "Unregistering all runners"

    gitlab-runner unregister --all-runners -c ${gitlab_runner_config_path}
    result=$?

    aws ssm put-parameter \
        --overwrite \
        --type SecureString \
        --name "${auth_token_ssm_param_name}" \
        --value="empty" \
        --region="${region}" \
        $KMS_KEY_CLAUSE 2>&1 >/dev/null | logger

    rm -f $lockfile
    return $result
}

restart() {
    stop
    start
}

reload() {
    :
}

status() {
    :
}

case "$1" in
    start)
        $1
        ;;
    stop)
        $1
        ;;
    restart)
        $1
        ;;
    status)
        $1
        ;;
    *)
        echo "Usage: $0 {start|stop|status|restart}"
        exit 2
        ;;
esac
