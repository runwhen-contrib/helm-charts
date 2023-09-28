# RunWhen Local Helm Chart

RunWhen Local is a container that discovers Kubernetes and cloud resources and generates a troubleshooting cheat sheet of commands - helping users quickly troubleshoot or debug applications and components. 

This helm chart is designed for running RunWhen Local inside of Kubernetes based environments. 

## Configuration Defaults
The default values in this helm chart will: 
- create a service account with **view** permissions at the **Cluster Scope**, enabling RunWhen Local to discover resources in all namespaces
- leverage in cluster authentication for discovering the cluster (supports a single cluster discovery only)
- leverage the `latest` [RunWhen Local image](https://github.com/runwhen-contrib/runwhen-local/pkgs/container/runwhen-local)
- not create an ingress object
- disable the in-browser terminal
- rediscover resources on an interval of 14400 seconds (4 hours)

For more information please refer to the [runwhen-local](https://docs.runwhen.com/public/v/runwhen-local) documentation or view [values.yaml](https://github.com/runwhen-contrib/helm-charts/blob/main/charts/runwhen-local/values.yaml)

## Prerequisites

- Kubernetes 1.23+
- Helm 3+

## Get Repository Info

```console
helm repo add runwhen-contrib https://runwhen-contrib.github.io/helm-charts
helm repo update
```
_See [`helm repo`](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

```console
helm install [RELEASE_NAME] runwhen-contrib/runwhen-local
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```console
helm upgrade [RELEASE_NAME] [CHART] --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

## Configuring

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values runwhen-contrib/runwhen-local
```

For more information please refer to the [runwhen-local](https://docs.runwhen.com/public/v/runwhen-local) documentation.