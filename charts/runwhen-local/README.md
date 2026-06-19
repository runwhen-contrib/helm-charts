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

Workers are long-running pods managed by the runner, each dedicated to a specific CodeCollection. They execute tasks defined as CodeBundles within their assigned CodeCollection. Each CodeCollection configured in the chart gets its own pool of worker replicas, and the runner handles their lifecycle (creation, scaling, and replacement). Workers inherit the runner's service account and security context.

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

# Runner relay service endpoints (default name; override via runner.serviceAccount.name)
kubectl get endpoints runner-relay -n <namespace>
```

### Inspecting the runner config

The runner reads its configuration from a ConfigMap. To verify the rendered config:

```console
# Default ConfigMap name (override via runner.configMap.name)
kubectl get configmap runner-config -n <namespace> -o yaml
```

### Multi-release deployments in one namespace

The chart's default resource names (`runner`, `runner-relay`,
`runner-config`, `otel-collector`, `workspace-builder`) are kept for
back-compat with runner-control's wire contract. If you need to deploy
two releases of this chart into the same namespace, override the
collision-class names in the second release's values file:

```yaml
runner:
  configMap:
    name: <release>-runner-config
  serviceAccount:
    create: true
    name: <release>-runner
  runEnvironment:
    deployment:
      serviceAccount: <release>-runner
    pod:
      serviceAccount: <release>-runner

workspaceBuilder:
  serviceAccount:
    name: <release>-workspace-builder
  workspaceInfo:
    configMap:
      name: <release>-workspace-builder

opentelemetry-collector:
  fullnameOverride: <release>-otel-collector
  serviceAccount:
    name: <release>-otel-collector
  configMap:
    existingName: <release>-otel-collector
```

### Customer overlays (commonLabels, podLabels, podAnnotations)

All chart-rendered resources (Deployments, Services, ConfigMaps, RBAC,
Ingresses) honour three top-level extension points so admission
policies, FinOps tagging, and service-mesh sidecar injection work
without a kustomize post-render layer:

```yaml
# Stamped on every chart-rendered resource's metadata.labels
commonLabels:
  cost-center: platform-eng
  compliance: pci

# Stamped on every chart-rendered pod template's spec.template.metadata.labels
podLabels:
  policy/enforce: baseline

# Stamped on every chart-rendered pod template's spec.template.metadata.annotations
podAnnotations:
  linkerd.io/inject: enabled
```

The `opentelemetry-collector` subchart does NOT inherit these — drive
its own knobs (`opentelemetry-collector.additionalLabels`,
`.podLabels`, `.podAnnotations`, `.podSecurityContext`) explicitly. See
[`values.yaml`](./values.yaml) for the complete overlay pattern.

### Restricted-cluster overlay (no ClusterRole + mandatory pod label + private CA)

A worked example combining the most common regulated-environment
constraints lives in
[`examples/values-restricted-byo.yaml`](./examples/values-restricted-byo.yaml):

1. Disables every cluster-scoped RBAC resource (`clusterRoleView` and
   `advancedClusterRole`) and grants a namespace-scoped `Role` instead.
2. Stamps a mandatory pod-template label
   (`policy.runwhen.io/profile: restricted`) for cluster-wide Kyverno /
   Gatekeeper policies, plus FinOps `commonLabels` on every resource.
   Chart 0.5.11+ propagates `commonLabels` and `podLabels` automatically
   into the runner ConfigMap so the runtime-spawned CronCodeRun
   Deployments and worker pods (which the chart never renders directly)
   ALSO satisfy admission policies. This requires runwhen-runner ≥
   v0.10.56 to honour the new `podLabels` field; older runners only
   stamp the Deployment-level metadata. Per-runEnvironment overrides
   live under `runner.runEnvironment.deployment.{labels,podLabels}` and
   `runner.runEnvironment.pod.{labels,podLabels}` (forward-compat).
3. Wires a corporate root-CA bundle on a non-proxy install — including
   the OTel collector subchart parity volume + env wiring.
4. Documents the optional **BYO ServiceAccount** path — pre-create the
   SAs + Roles + RoleBindings out-of-band (Crossplane / Terraform /
   GitOps overlay), then disable the chart-rendered ones. Three knobs
   matter for the runner because spawned CronCodeRun deployments and
   TaskSet pods reference the SA name through the runner ConfigMap, NOT
   just the runner pod itself:

   ```yaml
   runner:
     serviceAccount:
       create: false
       name: byo-runner-sa
     runEnvironment:
       deployment:
         serviceAccount: byo-runner-sa   # spawned CronCodeRun deployments
       pod:
         serviceAccount: byo-runner-sa   # spawned TaskSet pods
     otelCollector:
       serviceAccount:
         create: false                   # NEW knob (chart 0.5.9+) — disables parent OTel SA + Role + RoleBinding
   workspaceBuilder:
     serviceAccount:
       create: false
       name: byo-workspace-builder
   ```

   When `runEnvironment.*.serviceAccount` is left empty, the chart helper
   falls back to `runner.serviceAccount.name` automatically — but stale
   `"runner"` literals in older overlays will silently override the
   fallback and leave spawned workloads bound to a non-existent SA. Set
   all four explicitly on the BYO path.

   A turnkey companion manifest with all 14 SA + Role + RoleBinding +
   token Secret resources lives in
   [`examples/byo-rbac.yaml`](./examples/byo-rbac.yaml). Pre-apply it
   before `helm install`:

   ```console
   export RW_NAMESPACE=runwhen-local
   sed "s|__NAMESPACE__|$RW_NAMESPACE|g" \
     charts/runwhen-local/examples/byo-rbac.yaml | kubectl apply -f -
   ```

   Rules are mirrored verbatim from the chart 0.5.9 templates. If you
   bump chart versions and rules drift, regenerate using
   `helm template --show-only` against the four SA / RBAC templates.

```console
helm template rw charts/runwhen-local \
  -f charts/runwhen-local/examples/values-restricted-byo.yaml | \
  grep -E "^kind: ClusterRole"   # → 0 lines
```

### Common issues

| Symptom | Likely cause | Fix |
|---|---|---|
| Workspace builder pod in `CrashLoopBackOff` | Missing or invalid `workspaceInfo` configmap | Check `workspaceBuilder.workspaceInfo` values |
| Runner pod stuck in `Pending` | Insufficient resources or missing service account | Check `runner.resources` and verify the runner SA exists (default `runner`, override via `runner.serviceAccount.name`) |
| Service returns no endpoints | Label mismatch after upgrade | Verify pod labels with `kubectl get pods --show-labels` |
| Runner workloads fail to start | Service account mismatch in runner config | Check `runner.runEnvironment.deployment.serviceAccount` matches the rendered SA name |
| Two releases collide on RBAC / SAs / ConfigMaps | Default resource names are bare for runner-control back-compat | Use the override block above (Multi-release deployments) |
| Outbound TLS to private CA fails | `proxyCA` not configured | Set `proxyCA.secretName` (or `configMapName` + `key`); SSL_CERT_FILE / REQUESTS_CA_BUNDLE / CURL_CA_BUNDLE / NODE_EXTRA_CA_CERTS / GIT_SSL_CAINFO env vars are then automatically projected — independent of `proxy.enabled` |

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

If Helm reports that the workspace-builder Deployment `spec.selector` is immutable, delete the deployment once before retrying the upgrade:

```console
kubectl delete deployment <release-name>-workspace-builder -n <namespace>
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