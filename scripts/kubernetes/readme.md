```
docker build --build-arg K8S_VERSION=v1.8.0 .

docker cp $CONTAINER_ID:/opt/app-root/src/kubernetes-master-v1.8.0-1.noarch.rpm .
docker cp $CONTAINER_ID:/opt/app-root/src/kubernetes-node-v1.8.0-1.noarch.rpm .
```