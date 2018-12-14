#!/usr/bin/env bash

set -xe

KUBE_FOLDER="$HOME/.kube/kind-config-$CLUSTER_NAME"
KUBE_CONFIG="$KUBE_FOLDER/config"

create_cluster() {
  docker pull jdrouet/kindest-node:$KUBE_VERSION
  docker create \
    --name turkey-filling-$KUBE_VERSION \
    --network=host \
    -e KUBE_VERSION=$KUBE_VERSION \
    -e CLUSTER_NAME=$CLUSTER_NAME \
    -v /var/run/docker.sock:/var/run/docker.sock \
    jdrouet/kind-testing
  docker cp $GOPATH/src/github.com/docker/compose-on-kubernetes turkey-filling-$KUBE_VERSION:/go/src/github.com/docker/compose-on-kubernetes
  docker start --attach turkey-filling-$KUBE_VERSION
  mkdir -p $HOME/.kube
  docker cp turkey-filling-$KUBE_VERSION:/root/.kube/kind-config-$CLUSTER_NAME $HOME/.kube/
}

delete_cluster() {
  docker rm -f kind-$CLUSTER_NAME-control-plane
}

docker_cmd() {
  KUBECONFIG=$KUBE_FOLDER DOCKER_STACK_ORCHESTRATOR=kubernetes "$@"
}

case $1 in
  create)
    create_cluster
    ;;
  delete)
    delete_cluster
    ;;
  docker)
    docker_cmd "$@"
    ;;
  *)
    echo $"Usage: $0 {create|docker|delete}"
    exit 1
esac
