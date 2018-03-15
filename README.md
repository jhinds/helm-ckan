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

```
$ export REGISTRY=<registry> && \
     export TAG=<tag> && \
     export IMAGE=<image>

$ docker build -t $REGISTRY/$IMAGE:$TAG docker/$IMAGE && \
     docker push $REGISTRY/$IMAGE:$TAG
```

### Create Config Maps
Make sure you are pointed at the right Kubernetes cluster.  Verify by running:
`$ kubectl config current-context`

Now create the config maps for CKAN. This is not bundled in the docker image so the configuration is decoupled from the image.

```
$ kubectl apply -f configs/ -n ckan
```

### Create Helm Release
From the base repo directory
```
$ helm install helm/ckan -n ckan
```
