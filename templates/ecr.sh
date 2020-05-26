# Author - Aleksandr Fofanov

# Links:
# https://github.com/awslabs/amazon-ecr-credential-helper#amazon-linux-2
# https://docs.gitlab.com/ce/ci/docker/using_docker_images.html#using-credential-helpers
# https://gitlab.com/gitlab-org/gitlab-runner/issues/4426#note_280260662

yum install -y amazon-ecr-credential-helper

mkdir -p /root/.docker/
cat > /root/.docker/config.json << EOF
{
  "credHelpers": {
    "${account_id}.dkr.ecr.${region}.amazonaws.com": "ecr-login"
  }
}
EOF
