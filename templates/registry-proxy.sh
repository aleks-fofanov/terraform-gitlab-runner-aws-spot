# Author - Aleksandr Fofanov

# Links:
# https://about.gitlab.com/blog/2020/10/30/mitigating-the-impact-of-docker-hub-pull-requests-limits/
# https://docs.docker.com/registry/recipes/mirror/
# https://docs.gitlab.com/runner/configuration/autoscale.html#distributed-container-registry-mirroring

mkdir -p /root/.docker/

if [[ -f "/root/.docker/config.json" ]]; then
  cat <<< $(jq '.["registry-mirrors"] = ["https://mirror.gcr.io"]' /root/.docker/config.json) > /root/.docker/config.json
else
  cat > /root/.docker/config.json << EOF
{
  "registry-mirrors": ["https://mirror.gcr.io"]
}
EOF
fi
