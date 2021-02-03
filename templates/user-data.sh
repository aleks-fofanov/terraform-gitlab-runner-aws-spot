#!/bin/bash -ex

# Author - Aleksandr Fofanov

# Links:
# https://alestic.com/2010/12/ec2-user-data-output/

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

tee /etc/hosts <<EOL
127.0.0.1 localhost $(hostname)
EOL

# Make sure that network is available to proceed further
until ping -c1 www.google.com &>/dev/null; do
    echo "Waiting for network ..."
    sleep 1
done

#############################################################
# Install essential tools
#############################################################

yum -y update
yum install -y aws-cli jq

#############################################################
# Configure Logs
#############################################################

${logs_configuration}

#############################################################
# Install Docker
#############################################################

# Links:
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html#install_docker

amazon-linux-extras install docker

usermod -a -G docker ec2-user
systemctl enable docker
systemctl start docker

#############################################################
# Install Docker Machine
#############################################################

# Links:
# https://gitlab.com/gitlab-org/ci-cd/docker-machine/issues/4

curl -fL https://gitlab-docker-machine-downloads.s3.amazonaws.com/v${docker_machine_version}/docker-machine \
    -o /usr/local/bin/docker-machine
chmod +x /usr/local/bin/docker-machine
ln -s /usr/local/bin/docker-machine /usr/bin/docker-machine

docker-machine --version

# Create a dummy machine so that the cert is generated properly
# Links:
# https://gitlab.com/gitlab-org/gitlab-runner/issues/3676
# https://github.com/docker/machine/issues/3845#issuecomment-280389178

export USER=root
export HOME=/root
docker-machine create --driver none --url localhost dummy-machine
docker-machine rm -y dummy-machine
unset HOME
unset USER

#############################################################
# Registry Proxy for Docker Hub
#############################################################

${registry_proxy_for_dockerhub_configuration}

#############################################################
# Install and configure Gitlab Runner (+ ECR creds helper)
#############################################################

# Links:
# https://docs.gitlab.com/runner/register/#runners-configuration-template-file
# https://docs.gitlab.com/runner/commands/#registration-related-commands

mkdir -p /etc/gitlab-runner
cat > ${gitlab_runner_config_path} <<- \EOF
${gitlab_runner_config_content}
EOF

%{ if registry_proxy_for_dockerhub_enabled }
sed -i -e "s/ENGINE_REGISTRY_MIRROR_IP_ADDRESS/$(curl http://169.254.169.254/latest/meta-data/local-ipv4)/g" ${gitlab_runner_config_path}
%{ endif }

cat > ${template_config_path} <<- \EOF
${template_config_content}
EOF

curl -fL https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh | bash
yum install -y gitlab-runner-${gitlab_runner_version}

${ecr_configuration}

cat > /etc/rc.d/init.d/gitlab-runner-svc <<\EOF
${svc_script}
EOF

chmod a+x /etc/init.d/gitlab-runner-svc

chkconfig --add gitlab-runner-svc
chkconfig gitlab-runner-svc on

systemctl enable gitlab-runner

reboot
