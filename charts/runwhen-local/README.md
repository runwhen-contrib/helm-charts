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

# Runner relay service endpoints (default name is release-derived, e.g. <release>-runwhen-local-runner-relay)
kubectl get endpoints -l app.kubernetes.io/component=runner-relay -n <namespace>
```

### Inspecting the runner config

The runner reads its configuration from a ConfigMap. To verify the rendered config:

```console
# Default ConfigMap name is release-derived, e.g. <release>-runwhen-local-runner-config
kubectl get configmap -l app.kubernetes.io/component=runner -n <namespace> -o yaml
```

### Multi-release deployments in one namespace

Chart **0.7.0+** derives every collision-class resource name from the
release name (via the `runwhen-local.resourcePrefix` helper — the
release-derived fullname truncated to 32 chars plus a `-`), so multiple
releases can safely coexist in the same namespace with no manual
override. The chart also stamps the same prefix onto the runner via
the `RUNNER_RESOURCE_PREFIX` environment variable so the runtime
resources the runner creates (worker Deployments, cert-bundle
secrets, uploadinfo, exec-* pools, mcp-* Deployments, and the
outbound `RELAY_URL`) line up with the chart-side names.

Renamed resources (bare → release-derived):

| Old bare name | New default |
|---|---|
| `runner` (ServiceAccount / Role / RoleBinding) | `{prefix}runner*` |
| `runner-config` (ConfigMap) | `{prefix}runner-config` |
| `runner-relay` (Service) | `{prefix}runner-relay` |
| `otel-collector` (parent-rendered SA / Role / RoleBinding / ConfigMap) | `{prefix}otel-collector*` |
| `workspace-builder` (SA / ConfigMap / Roles / RoleBindings) | `{prefix}workspace-builder*` |
| `{namespace}-workspace-builder-view-crb` (cluster-scoped) | `{prefix}workspace-builder-view-crb` |
| `uploadinfo` (Secret, runner-written) | `{prefix}uploadinfo` |
| `kubeconfig` (Secret, workspace-builder-written; `custom.kubeconfig_secret_name`) | `{prefix}kubeconfig` |
| `runner-metrics-tls` (Secret, runner-written) | `{prefix}runner-metrics-tls` |

The trunc-32 budget on the prefix keeps every composed name within
Kubernetes' 63-char DNS label limit. Deployment names
(`{release}-runwhen-local-runner` and
`{release}-runwhen-local-workspace-builder`) keep their existing
trunc-44 behavior — they were already release-derived and unique.

**Explicit-name escape hatch.** Every helper still honours an
explicit `.Values...name` override. Set the name to anything you want
(e.g. an admission-policy-approved literal, a pre-created BYO SA):

```yaml
runner:
  serviceAccount:
    create: true
    name: my-runner-sa   # overrides {prefix}runner
  configMap:
    name: my-runner-config

workspaceBuilder:
  serviceAccount:
    name: my-workspace-builder
  workspaceInfo:
    configMap:
      name: my-workspace-info
```

Explicit overrides work identically in single-release and multi-release
setups.

**Multi-release OTel subchart (auto-prefixed, chart 0.7.0+).** The
bundled `opentelemetry-collector` subchart is now auto-prefixed: the
parent chart shadows the subchart's `fullname` and `serviceAccountName`
templates (which the subchart renders in its own context) so its
Deployment / Service / ServiceAccount default to the same
release-derived `{prefix}` as every parent-rendered resource, and the
subchart's `configMap.existingName` and `extraVolumes[].secret.secretName`
are set to templates that resolve via the
`runwhen-local.otelSubchartPrefix` / `runwhen-local.runnerMetricsTls`
helpers. No override is needed for a standard multi-release install.

Every knob still honours an explicit override — set any of them to a
literal to pin the name (e.g. an admission-policy-approved value):

```yaml
opentelemetry-collector:
  fullnameOverride: my-release-runwhen-local-otel-collector
  serviceAccount:
    name: my-release-runwhen-local-otel-collector
  configMap:
    existingName: my-release-runwhen-local-otel-collector
  extraVolumes:
    - name: tls-secret-volume
      secret:
        secretName: my-release-runwhen-local-runner-metrics-tls
    # preserve any additional volumes (e.g. proxy-ca) here
```

The default prefix is `{prefix}` = the release-derived fullname
(`{release-name}` when the release name already contains
`runwhen-local`, else `{release-name}-runwhen-local`) truncated to 32
chars with a trailing `-` — e.g. release `rwl` → `rwl-runwhen-local-`.
It derives from the release name only (not `nameOverride` /
`fullnameOverride`), because the bundled `opentelemetry-collector`
subchart renders in its own values scope and cannot see the parent's
overrides; a release-only derivation is what keeps the parent chart and
the subchart from disagreeing on the prefix.

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
| Runner pod stuck in `Pending` | Insufficient resources or missing service account | Check `runner.resources` and verify the release-derived runner SA exists (default `{prefix}runner`, override via `runner.serviceAccount.name`) |
| Service returns no endpoints | Label mismatch after upgrade | Verify pod labels with `kubectl get pods --show-labels` |
| Runner workloads fail to start | Service account mismatch in runner config | Check `runner.runEnvironment.deployment.serviceAccount` resolves to the rendered SA name (leave empty to inherit the release-derived default; stale `"runner"` literals in older overlays silently override this) |
| Two releases collide on RBAC / SAs / ConfigMaps | Legacy chart pre-0.7.0 default names were bare (`runner`, `runner-config`, `workspace-builder`, …) | Upgrade to chart 0.7.0+ — every collision-class resource, including the bundled OTel subchart, is now automatically release-derived (see "Multi-release deployments" above) |
| Runner Deployment env missing `RUNNER_RESOURCE_PREFIX` | Chart pre-0.7.0 or runner image without prefix support | Bump chart to 0.7.0+ AND update the runwhen-runner image to a version that reads `RUNNER_RESOURCE_PREFIX` |
| OTel collector `CreateContainerConfigError` mounting `runner-metrics-tls` | Runner image supports `RUNNER_RESOURCE_PREFIX` and writes `{prefix}runner-metrics-tls`, but the chart is pre-0.7.0 (OTel secretName not yet auto-prefixed) | Upgrade the chart to 0.7.0+ — the default OTel mount resolves to `{prefix}runner-metrics-tls` automatically (or pin the 4 subchart keys explicitly per the "Multi-release OTel subchart" block) |
| Outbound TLS to private CA fails | `proxyCA` not configured | Set `proxyCA.secretName` (or `configMapName` + `key`); SSL_CERT_FILE / REQUESTS_CA_BUNDLE / CURL_CA_BUNDLE / NODE_EXTRA_CA_CERTS / GIT_SSL_CAINFO env vars are then automatically projected — independent of `proxy.enabled` |

### Upgrading to 0.7.0 (release-name prefixing)

Chart **0.7.0** is a deliberate breaking change: every collision-class
resource that used to be bare (`runner`, `runner-config`,
`runner-relay`, `otel-collector`, `workspace-builder`, `uploadinfo`,
`runner-metrics-tls`, and the namespace-derived
`{namespace}-workspace-builder-view-crb`) is now release-derived
through the new `runwhen-local.resourcePrefix` helper. Multiple
releases can safely coexist in one namespace with **no manual
override** for chart-rendered resources.

Wire contract with runwhen-runner:

- The chart always sets `RUNNER_RESOURCE_PREFIX={prefix}` on the
  runner container (see `templates/runner-deployment.yaml`).
- **The runner image MUST be a version that reads
  `RUNNER_RESOURCE_PREFIX`** — otherwise the runner will write bare
  names (`runner-metrics-tls`, `uploadinfo`, worker deployments, SA
  refs) that no longer match the chart-side names, and the collector /
  spawned workloads / cert-mount references will fail.
- Empty prefix reproduces today's names byte-identical on the runner
  side, so docker installs and non-chart runners are unaffected.

Coordinate the runner image bump with the chart bump (or override the
chart's `RUNNER_RESOURCE_PREFIX` env to empty via
`runner.extraEnv` on the runner-first upgrade path).

Renamed resources (bare → release-derived default; every helper still
honours an explicit `.name` override):

| Old bare name | New default |
|---|---|
| `runner` (ServiceAccount) | `{prefix}runner` |
| `runner-role` / `runner-rolebinding` | `{prefix}runner-role` / `{prefix}runner-rolebinding` |
| `runner-config` (ConfigMap) | `{prefix}runner-config` |
| `runner-relay` (Service) | `{prefix}runner-relay` |
| `otel-collector` (parent-rendered SA) | `{prefix}otel-collector` |
| `otel-collector-role` / `otel-collector-rolebinding` | `{prefix}otel-collector-role` / `{prefix}otel-collector-rolebinding` |
| `otel-collector` (parent-rendered ConfigMap) | `{prefix}otel-collector` |
| `workspace-builder` (ServiceAccount) | `{prefix}workspace-builder` |
| `workspace-builder-token` (SA token Secret) | `{prefix}workspace-builder-token` |
| `workspace-builder-sa-local-view` / `-rb` (Role/RoleBinding) | `{prefix}workspace-builder-sa-local-view` / `-rb` |
| `workspace-builder-sa-secret-manage` / `-rb` (Role/RoleBinding) | `{prefix}workspace-builder-sa-secret-manage` / `-rb` |
| `workspace-builder-advanced-view` / `workspace-builder-advanced-crb` (ClusterRole/ClusterRoleBinding, only when `advancedClusterRole.enabled=true`) | `{prefix}workspace-builder-advanced-view` / `{prefix}workspace-builder-advanced-crb` |
| `{namespace}-workspace-builder-view-crb` (ClusterRoleBinding) | `{prefix}workspace-builder-view-crb` |
| `workspace-builder` (workspaceInfo ConfigMap) | `{prefix}workspace-builder` |
| `uploadinfo` (runner-written Secret; workspaceBuilder mount reference) | `{prefix}uploadinfo` |
| `kubeconfig` (workspace-builder-written Secret; `custom.kubeconfig_secret_name` reference) | `{prefix}kubeconfig` |
| `runner-metrics-tls` (runner-written Secret; OTel mount reference) | `{prefix}runner-metrics-tls` |

Input Secret **operators must create / rename**:

| Old name | New name | Notes |
|---|---|---|
| `runner-registration-token` | `{prefix}runner-registration-token` | The runner reads this Secret at boot to register with the platform. It is NOT chart-rendered; you (or your GitOps overlay) create it out-of-band. Rename it before restarting the runner Deployment after the upgrade |

Upgrade steps:

1. Bump the chart to 0.7.0 and the runwhen-runner image to a version
   that reads `RUNNER_RESOURCE_PREFIX` in the same operation (or use
   the compatibility escape hatch above).
2. Pre-create / rename the `{prefix}runner-registration-token` Secret
   in the release namespace.
3. The bundled OTel subchart is auto-prefixed via parent-side shadows
   of its `fullname` / `serviceAccountName` templates, and its
   `configMap.existingName` / `extraVolumes[].secret.secretName`
   default to release-derived templates — no override needed for the
   default mTLS metrics setup (`runner.metrics.mtls.enabled=true`).
   Pin any of those keys explicitly if your environment requires
   literal names (see "Multi-release OTel subchart" above).
4. `helm upgrade [RELEASE_NAME] runwhen-contrib/runwhen-local --install`.
5. Helm will create the new release-derived resources and stop
   managing the old bare-named ones. Delete the old resources by
   label / by name:

   ```console
   kubectl -n <namespace> delete sa,role,rolebinding,configmap,service \
     runner runner-role runner-rolebinding runner-config runner-relay \
     otel-collector otel-collector-role otel-collector-rolebinding \
     workspace-builder \
     --ignore-not-found
   kubectl -n <namespace> delete secret \
     workspace-builder-token uploadinfo runner-metrics-tls kubeconfig \
     --ignore-not-found
   kubectl delete clusterrolebinding <namespace>-workspace-builder-view-crb --ignore-not-found
   ```

If Helm reports that the workspace-builder or runner Deployment's
`spec.selector` is immutable, delete the Deployment once before
retrying the upgrade — pod selectors carry `app.kubernetes.io/instance`
which is release-safe, so this only bites operators whose overlays
pinned selectors manually.

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