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
- Pin the [workspace builder image](https://github.com/runwhen-contrib/runwhen-local/pkgs/container/runwhen-local) to the chart `appVersion` (not `latest`; see `.cursor/skills/sync-rwl-image-version/SKILL.md` when bumping)
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

### Upgrading with hosted MCP servers enabled

If your release has `runner.mcp.hosted.enabled: true`, two behaviours changed
that are worth checking before you upgrade a production install. `helm
upgrade` also prints these as part of `NOTES.txt` — re-read the output.

**1. Hosted MCP pods now run under a dedicated ServiceAccount, not the
runner's own SA — and that is an intentional, non-reversible-by-default
breaking change.**

Earlier hosted-MCP defaults ran the hosted pod under the runner's own
ServiceAccount. On GKE (and any cluster using metadata-server-based cloud
identity — Workload Identity, IRSA, etc.), that hands third-party npm/PyPI
code running in the hosted pod the runner's cloud identity, regardless of
whether a Kubernetes token is mounted. `runner.mcp.hosted.serviceAccount.create`
now defaults to `true` and the chart renders a dedicated, deliberately
UNANNOTATED ServiceAccount for hosted pods instead.

**On upgrade, if a hosted server was inadvertently relying on the runner's
cloud identity (e.g. reading a cloud secret, calling a cloud API), it LOSES
that access the moment this default takes effect.** There is deliberately
**no** backward-compatible default that keeps the old sharing behaviour —
that behaviour is the exact security gap this change closes, so silently
preserving it on upgrade would silently preserve the gap. If you need a
transition window while you re-provision cloud identity for the dedicated
SA (or decide it doesn't need one), opt back into the old behaviour
**explicitly**:

```yaml
runner:
  mcp:
    hosted:
      serviceAccount:
        create: false
        name: "runner"   # or whatever runner.serviceAccount.name is set to
```

This must be set explicitly — a bare `serviceAccount.create: false` with no
`name` does **not** fall back to the runner's SA; it resolves to the
namespace's implicit `default` ServiceAccount instead (see `values.yaml`
for the full resolution order). That is also a deliberate change from
earlier chart behaviour, for the same reason.

**2. Hosted pods get CPU/memory requests+limits and an ephemeral-storage
cap for the first time.**

A hosted pod runs arbitrary third-party npm/PyPI code fetched at startup;
without limits, one hosted server could consume unbounded CPU/memory or
fill a node's ephemeral storage. `runner.mcp.hosted.resources` now ships
non-empty defaults (100m/1 CPU, 256Mi/512Mi memory, 2Gi ephemeral-storage
per volume — sized for a lightweight CLI-wrapper server). **A hosted server
with a heavier dependency tree (native compilation, large wheels) can start
being OOMKilled or CPU-throttled on upgrade where it previously was not.**
Watch for `OOMKilled` hosted pods after upgrading. To keep the old
(unbounded) behaviour for a transition window, blank the value you need —
this omits that setting entirely rather than falling back to a Kubernetes
default:

```yaml
runner:
  mcp:
    hosted:
      resources:
        limits:
          memory: ""   # or cpu: "", or ephemeralStorageSizeLimit: ""
```

Prefer raising the limit over blanking it once you know the real
requirement — blanking removes the protection this change adds.

**3. `registryOverride` implication for mirrored / air-gapped registries.**

`runner.image` and `runner.mcp.hosted.image` now default their
`registry`/`repository` to `""` instead of a hardcoded vendor registry, so
that `runwhen-local.image` actually honours `registryOverride` for these
two images (previously, their non-empty defaults meant `registryOverride`
was silently ignored for the runner and hosted-MCP images specifically,
even when set — see `values.yaml`). If you mirror images into a private
registry and already set `.Values.registryOverride`, this upgrade will,
for the first time, actually pull the runner and `runner-mcp-host` images
from your mirror instead of the vendor registry. **Confirm both images are
present in your mirror before upgrading**, or these pods will
`ImagePullBackOff`.

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

   **Combining BYO RBAC with hosted MCP** (`runner.mcp.hosted.enabled:
   true`): `runner.serviceAccount.create: false` disables the
   chart-rendered runner Role/RoleBinding entirely, including the
   `services` rule hosted MCP needs to create a hosted server's Service.
   The chart FAILS the render on this combination unless you acknowledge
   you've granted that rule yourself:

   ```yaml
   runner:
     rbac:
       hostedProvided: true   # only after adding the `services` rule from byo-rbac.yaml to your Role
   ```

   Leaving `hostedProvided: false` (the default) is deliberate: a runner
   with `serviceAccount.create: false` and no acknowledgement has no way
   to create hosted-server Services, so installing it anyway would only
   fail later, at runtime, with `Forbidden`.

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
| `helm install`/`upgrade` fails with "runner.mcp.hosted.enabled is true and runner.serviceAccount.create is false..." | BYO runner RBAC (`runner.serviceAccount.create: false`) skips the chart-rendered Role, which normally carries the `services` rule hosted MCP needs | Grant that rule on your externally-managed Role (see `examples/byo-rbac.yaml`) and set `runner.rbac.hostedProvided: true` |
| Hosted MCP server `Forbidden` creating a Service at runtime | Runner's SA lacks the `services` RBAC rule (installed anyway, e.g. on an older chart before the render-time check existed) | Same fix as above |
| Hosted MCP pod `OOMKilled` after upgrading | `runner.mcp.hosted.resources` limits now apply by default | Raise (or temporarily blank) the relevant `runner.mcp.hosted.resources.*` value — see "Upgrading with hosted MCP servers enabled" |

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

### Upgrading to 0.6.0 (runwhen-local FastAPI)

Chart **0.6.0** targets [runwhen-local](https://github.com/runwhen-contrib/runwhen-local) **0.11.0+**, which replaces the legacy Django/MkDocs sidecar with a single **FastAPI** server on port **8000**:

| Surface | Pre-0.6.0 | 0.6.0+ |
|---|---|---|
| UI / cheat sheet | MkDocs on service port **8081** | FastAPI landing page + `/explorer/` on port **8000** |
| API / health | Django on port **8000** (`tcpSocket` probes) | FastAPI on port **8000** (`GET /health/` HTTP probes) |
| Default `workspaceBuilder.service.port` | `8081` | `8000` |
| Named container/service port | `django`, `mkdocs` | `api` |

When upgrading:

1. Bump the workspace-builder image to `0.11.0` or later (chart `appVersion` default).
2. If you set `workspaceBuilder.service.port: 8081` or `ingress` backends targeting port 8081, change them to **8000**.
3. If you override probes with `port: django` or `port: mkdocs`, switch to `port: api` and `httpGet.path: /health/`.
4. Update any NetworkPolicies or ingress rules that allow port **8081** to the workspace-builder Service to use **8000** instead.

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