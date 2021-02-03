# Author - Aleksandr Fofanov

# Links:
# https://about.gitlab.com/blog/2020/10/30/mitigating-the-impact-of-docker-hub-pull-requests-limits/
# https://docs.docker.com/registry/recipes/mirror/
# https://docs.gitlab.com/runner/configuration/autoscale.html#distributed-container-registry-mirroring

docker run -d -p ${port}:5000 \
    -e REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io \
    --restart always \
    --name registry registry:2
