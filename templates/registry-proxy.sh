# Author - Aleksandr Fofanov

# Links:
# https://about.gitlab.com/blog/2020/10/30/mitigating-the-impact-of-docker-hub-pull-requests-limits/
# https://docs.docker.com/registry/recipes/mirror/
# https://docs.gitlab.com/runner/configuration/autoscale.html#distributed-container-registry-mirroring

docker run -d -p ${port}:5000 \
    -e REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io \
    --restart always \
    --name registry registry:2

mkdir -p /root/.docker/

if [[ -f "/root/.docker/config.json" ]]; then
  cat <<< $(jq '.["registry-mirrors"] = ["http://127.0.0.1:${port}"]' /root/.docker/config.json) > /root/.docker/config.json
else
  cat > /root/.docker/config.json << EOF
{
  "registry-mirrors": ["http://127.0.0.1:${port}"]
}
EOF
fi

sed -i -e "s/REGISTRY_MIRROR_IP_ADDRESS/$(curl http://169.254.169.254/latest/meta-data/local-ipv4)/g" ${gitlab_runner_config_path}
