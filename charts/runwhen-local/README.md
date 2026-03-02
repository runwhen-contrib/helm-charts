# RunWhen Local Helm Chart

This Helm chart deploys [RunWhen Local](https://www.runwhen.com) into Kubernetes environments. It installs the **Workspace Builder**, a **Runner**, and supporting infrastructure that together provide automated discovery of your environment and private execution of troubleshooting and operational tasks from the [RunWhen Platform](https://docs.runwhen.com/platform-documentation).

## Components

### Workspace Builder

The workspace builder scans your Kubernetes clusters and cloud accounts, matching discovered resources against applicable troubleshooting commands found in CodeCollection repositories. Its output is used to automatically build and maintain a workspace in the [RunWhen Platform](https://docs.runwhen.com/platform-documentation). The workspace builder runs on a configurable interval, continuously keeping the workspace in sync as your environment changes.

### Runner

The runner is a locally deployed agent that connects to the [RunWhen Platform](https://docs.runwhen.com/platform-documentation) and executes tasks privately within your infrastructure. Tasks are defined as CodeBundles in CodeCollection repositories, and the full catalog is available at [registry.runwhen.com](https://registry.runwhen.com). The runner handles two types of work:

- **Tasks** -- investigative troubleshooting or operational readiness checks initiated by a user or Digital Assistant. Results are sent back to the RunWhen Platform.
- **Health checks (SLIs)** -- continuous measurements of service health, pushed as metrics to the RunWhen Platform.

### Workers

Workers are short-lived pods created by the runner to execute individual tasks. Each CodeCollection configured in the chart gets its own pool of worker replicas. Workers inherit the runner's service account and security context, and are automatically managed (created, scaled, and cleaned up) by the runner.

## Configuration Defaults

The default values in this helm chart will:
- Create a service account with **view** permissions at the **cluster scope**, enabling the workspace builder to discover resources in all namespaces
- Use in-cluster authentication for discovery (single-cluster only)
- Use the `latest` [workspace builder image](https://github.com/runwhen-contrib/runwhen-local/pkgs/container/runwhen-local)
- Enable the runner with the [rw-cli-codecollection](https://github.com/runwhen-contrib/rw-cli-codecollection)
- Not create an ingress object
- Rediscover resources every 14400 seconds (4 hours)

For full configuration details see [values.yaml](./values.yaml) or the [RunWhen Platform documentation](https://docs.runwhen.com/platform-documentation).

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

For more information see the [RunWhen Platform documentation](https://docs.runwhen.com/platform-documentation).

## Troubleshooting

All chart resources carry standard Kubernetes labels including `app.kubernetes.io/component` so you can quickly isolate the workspace builder from the runner.

### Identifying pods by component

```console
# Workspace builder pods only
kubectl get pods -l app.kubernetes.io/component=workspace-builder -n <namespace>

# Runner pods only
kubectl get pods -l app.kubernetes.io/component=runner -n <namespace>
```

### Viewing logs

```console
# Workspace builder logs
kubectl logs -l app.kubernetes.io/component=workspace-builder -n <namespace> -f

# Runner logs
kubectl logs -l app.kubernetes.io/component=runner -n <namespace> -f
```

### Checking resource status

```console
# List all resources created by this release
kubectl get all -l app.kubernetes.io/instance=<release-name> -n <namespace>

# Describe the workspace builder deployment
kubectl describe deployment <release-name>-workspace-builder -n <namespace>

# Describe the runner deployment
kubectl describe deployment <release-name>-runner -n <namespace>
```

### Verifying service selectors

If the workspace builder UI is unreachable or the runner relay is not responding, confirm the services are targeting the correct pods:

```console
# Workspace builder service endpoints
kubectl get endpoints <release-name>-workspace-builder -n <namespace>

# Runner relay service endpoints
kubectl get endpoints runner-relay -n <namespace>
```

### Inspecting the runner config

The runner reads its configuration from a ConfigMap. To verify the rendered config:

```console
kubectl get configmap runner-config -n <namespace> -o yaml
```

### Common issues

| Symptom | Likely cause | Fix |
|---|---|---|
| Workspace builder pod in `CrashLoopBackOff` | Missing or invalid `workspaceInfo` configmap | Check `workspaceBuilder.workspaceInfo` values |
| Runner pod stuck in `Pending` | Insufficient resources or missing service account | Check `runner.resources` and verify the `runner` SA exists |
| Service returns no endpoints | Label mismatch after upgrade | Verify pod labels with `kubectl get pods --show-labels` |
| Runner workloads fail to start | Service account mismatch in runner config | Check `runner.runEnvironment.deployment.serviceAccount` in values |

### Upgrading from pre-0.5.0

Chart 0.5.0 renames several resources and the primary values key:

- The values key `runwhenLocal` is now `workspaceBuilder`. Existing values files using `runwhenLocal` continue to work via an automatic merge, but should be migrated.
- Deployments are now named `<release>-workspace-builder` and `<release>-runner`.
- The workspace builder service is now named `<release>-workspace-builder`.

On upgrade, Helm will create new resources with the updated names. The old-named resources are no longer managed and should be cleaned up:

```console
kubectl delete deployment <old-release-name> -n <namespace>
kubectl delete service runwhen-local -n <namespace>
```

## CodeCollections Runner Configuration

The runner component supports configuring multiple code collections with specific repositories, tags/branches/refs, and worker replicas. This allows you to deploy and manage different versions of code collections based on your requirements.

### Example Configuration

```yaml
runner:
  enabled: true
  codeCollections:
    - repoURL: https://github.com/runwhen-contrib/rw-public-codecollection.git
      tag: v0.0.17
      workerReplicas: 1
    - repoURL: https://github.com/runwhen-contrib/rw-cli-codecollection.git
      tag: v0.0.24
      workerReplicas: 2
    - repoURL: https://github.com/runwhen-contrib/rw-workspace-utils.git
      tag: v0.0.3
      workerReplicas: 1
    - repoURL: https://github.com/runwhen-contrib/rw-generic-codecollection.git
      tag: v0.0.1
      workerReplicas: 1
```

### Configuration Options

Each code collection entry supports the following fields:

- `repoURL` (required): The Git repository URL for the code collection
- `tag` (optional): Use a specific Git tag
- `branch` (optional): Use a specific Git branch (alternative to tag)
- `ref` (optional): Use a specific Git commit ref (alternative to tag/branch)
- `workerReplicas` (optional): Number of worker replicas to deploy (defaults to 1)
- `name` (optional): Custom name for the collection (defaults to repository name)

**Note**: Only one of `tag`, `branch`, or `ref` should be specified per collection. If none are specified, it defaults to `main` branch.