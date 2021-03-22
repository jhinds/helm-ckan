# Helm CKAN

This repo serves to help deploy CKAN onto Kubernetes via Helm.

### Prerequisites
- [docker](https://docs.docker.com/install/) if you want to build your own CKAN image
- [helm](https://github.com/kubernetes/helm#install) to deploy to kubernetes
- a running kubernetes cluster, you can install [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) to test locally.

### Build Dockerfile
From the base repo directory where:
- `REGISTRY=<registry>` is your docker registry or username.
- `TAG=<tag>` is the tag of the image.
- `IMAGE=<image>` is the name of the image in the [docker](docker) directory. Options are `ckan`, and `ckan-postgres`, `ckan-solr`.

```bash
$ export REGISTRY=<registry> && \
     export TAG=<tag> && \
     export IMAGE=<image>

$ docker build -t $REGISTRY/$IMAGE:$TAG docker/$IMAGE && \
     docker push $REGISTRY/$IMAGE:$TAG
```

### Create Helm Release
From the base repo directory
```bash
# template out files to check output
$ helm template ckan helm/ckan --namespace ckan --create-namespace

$ helm install ckan helm/ckan --namespace ckan --create-namespace
```

### Upgrade Helm Release
```bash
$ helm upgrade ckan helm/ckan --namespace ckan
```