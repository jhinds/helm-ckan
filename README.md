# Helm CKAN

This repo serves to help deploy CKAN onto kubernetes via Helm.

### Prerequisites
- [docker](https://docs.docker.com/install/) if you want to build your own CKAN image
- [helm](https://github.com/kubernetes/helm#install) to deploy to kubernetes
- a running kubernetes cluster, you can install [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) to test locally.

### Build Dockerfile
From the parent directory
```
$ export REPO=<your repo> && \
     export TAG=2.7.2 && \
     docker build -t $REPO/ckan:$TAG docker/ && \
     docker push $REPO/ckan:$TAG
```
