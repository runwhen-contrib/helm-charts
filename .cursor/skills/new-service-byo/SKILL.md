---
name: new-service-byo
description: >-
  Enterprise BYO checklist for any new service or workload added to the
  runwhen-local Helm chart. Use when adding a Deployment, StatefulSet, Job,
  CronJob, DaemonSet, or hook under charts/runwhen-local/templates/, or when
  retrofitting an existing template that's missing common-labels propagation,
  pod-template labels, hardened SecurityContext, ServiceAccount overrides,
  registry overrides, proxy / proxyCA wiring, scratch volumes, scheduling
  knobs, or any other BYO extension point. Also covers the
  opentelemetry-collector subchart caveat and unit-test expectations.
---

# Enterprise BYO checklist — new service in `runwhen-local`

Every workload added to `charts/runwhen-local/templates/` MUST consume the
BYO extension points the chart already exposes (and add the missing ones
when relevant). These knobs exist because real customer clusters
(federal, banking, regulated, airgapped, OpenShift restricted-v2,
auto-injecting service-mesh) enforce them via admission webhooks, FinOps
tooling, and registry-pull-auth proxies. Skipping one means a kustomize
post-render layer on the customer side — exactly what each knob exists
to eliminate.

This chart is the small sibling of `runwhen-platform` (in the
`runwhen/rwlight-helm` repo). The platform chart's
`new-service-byo` skill is the long-form reference; this skill mirrors
the rules, adapted to the smaller surface area of `runwhen-local`
(workspace-builder + runner + bundled OpenTelemetry collector).

**Always apply this skill when**:
- Adding a new template under `charts/runwhen-local/templates/`
- Adding a new `Job`, `CronJob`, `Deployment`, `StatefulSet`, or hook
- Retrofitting an existing template that's missing knobs
- Reviewing a PR that touches a template's pod spec
- Asked about `registryOverride`, `imagePullSecrets`, `proxy.*`,
  `proxyCA.*`, `containerSecurityContext`, `podSecurityContext`,
  `nodeSelector`, `tolerations`, `affinity`, `serviceAccount.*.name`,
  or any `*.enabled` gating.

## The Eleven Checklist (mandatory for every pod-bearing workload)

Copy this checklist into the PR description / commit body. Every box must
be checked before the template merges.

```
- [ ]  1. Render-gate           — `{{- if .Values.<service>.enabled }}` (or .deploy)
- [ ]  2. Labels                — `runwhen-local.labels` (or component variant) on metadata,
                                 — selector helper on spec.selector
- [ ]  3. Pod-template labels   — selector helper + (TODO: `runwhen-local.podLabels`) + component label
- [ ]  4. Pod annotations       — `with .Values.<service>.podAnnotations` AND (TODO:
                                  `runwhen-local.podAnnotations` for global sidecar/audit/inject)
- [ ]  5. Pod SecurityContext   — `runwhen-local.podSecurityContext`
- [ ]  6. Container SecCtx      — `runwhen-local.containerSecurityContext` per container
- [ ]  7. Init-container SecCtx — same helper per initContainer (no separate helper today)
- [ ]  8. ServiceAccount        — fullname-prefixed (`{{ include "runwhen-local.fullname" . }}-<role>`),
                                  honour `serviceAccount.create=false` and `serviceAccount.name`
- [ ]  9. Scheduling            — `nodeSelector` / `tolerations` / `affinity` from `.Values`
                                  (top-level + per-service merged)
- [ ] 10. Trust bundle / proxyCA — `proxy.enabled` + `proxyCA.{secretName,configMapName,key}`,
                                  mount + emit SSL_CERT_FILE / REQUESTS_CA_BUNDLE / CURL_CA_BUNDLE /
                                  NODE_EXTRA_CA_CERTS / GIT_SSL_CAINFO env vars
- [ ] 11. Image resolution      — honour `.Values.registryOverride` + per-image
                                  `<service>.image.{registry,repository,tag,pullPolicy}`
                                  + top-level `.Values.imagePullSecrets`
```

Plus, **when applicable**:

```
- [ ] Tunable probes              — startupProbe / readinessProbe / livenessProbe
                                    overridable via values block
- [ ] Resources matrix            — `<svc>.resources.default` and `.EKS_Fargate`
                                    (mirror `workspaceBuilder.resources` shape)
- [ ] arm64 toleration            — only when `.Values.platformArch == "arm64"`
- [ ] automountServiceAccountToken — opt-out (top-level or per-service knob);
                                     do NOT hardcode `true`
- [ ] Helm hooks (Jobs only)      — helm.sh/hook + hook-weight + hook-delete-policy
- [ ] Conditional volumes/Mounts  — `{{- if … }}` gates so empty blocks don't render
- [ ] Resource name prefixing     — every resource name MUST include `runwhen-local.fullname`
                                    (no bare `runner`, `runner-relay`, `runner-role`...
                                    — they collide on a second release in same namespace)
- [ ] values.yaml block           — .enabled / .resources / .image / .probes + inline docs
- [ ] tests/                      — unit-test under `tests/<service>_test.yaml` (helm unittest)
- [ ] README troubleshooting note — extend "Identifying pods by component" section
```

## Helpers that EXIST today (`charts/runwhen-local/templates/_helpers.tpl`)

| Helper                                          | Purpose                                                                     |
|-------------------------------------------------|-----------------------------------------------------------------------------|
| `runwhen-local.name`                            | chart name truncated to 63                                                  |
| `runwhen-local.fullname`                        | `<release>-<chart>` (or `fullnameOverride`), truncated to 63                |
| `runwhen-local.chart`                           | `<chart>-<version>` for `helm.sh/chart` label                               |
| `runwhen-local.labels`                          | shared labels (chart + app.kubernetes.io/* + version + managed-by + commonLabels) |
| `runwhen-local.selectorLabels`                  | base selector (`app.kubernetes.io/name` + `instance`)                       |
| `runwhen-local.workspaceBuilderFullname`        | `<fullname>-workspace-builder` (44-char truncate to leave room for suffix)  |
| `runwhen-local.workspaceBuilderSelectorLabels`  | wb selector (`name` = wb-fullname + instance + `component=workspace-builder`) |
| `runwhen-local.workspaceBuilderLabels`          | wb labels (chart + wb-selector + version + managed-by + commonLabels)       |
| `runwhen-local.runnerFullname`                  | `<fullname>-runner` (44-char truncate)                                      |
| `runwhen-local.runnerSelectorLabels`            | shared selector + `component=runner`                                        |
| `runwhen-local.runnerLabels`                    | shared labels + `component=runner` (inherits commonLabels via labels)       |
| `runwhen-local.podLabels`                       | merged `.Values.podLabels` + `.Values.commonLabels` for pod templates       |
| `runwhen-local.podAnnotations`                  | render-or-nothing `annotations:` block from `.Values.podAnnotations`        |
| `runwhen-local.image`                           | `<registry>/<repo>:<tag>` resolver honouring `.Values.registryOverride`     |
| `runwhen-local.trustBundleEnv`                  | emit 5 SSL/CA env vars when `.Values.proxyCA` is set (decoupled from proxy) |
| `runwhen-local.serviceAccountName`              | resolves wb SA name with `serviceAccount.create` honoured                   |
| `runwhen-local.serviceAccountName.runner`       | resolves runner SA name (default `runner`, override via `runner.serviceAccount.name`) |
| `runwhen-local.serviceAccountName.otelCollector`| resolves OTel collector SA name (default `otel-collector`, override via `runner.otelCollector.serviceAccount.name`) |
| `runwhen-local.workspaceName`                   | echoes `.Values.workspaceName`                                              |
| `runwhen-local.containerSecurityContext`        | render-or-nothing for `.Values.containerSecurityContext`                    |
| `runwhen-local.podSecurityContext`              | render-or-nothing for `.Values.podSecurityContext`                          |
| `runwhen-local.resolveWorkspaceBuilder`         | back-compat for legacy `runwhenLocal:` values key                           |

## Helpers that SHOULD exist (TODO: add when retrofitting)

The platform chart (`runwhen-platform`) ships these; mirror them here when
the chart grows or you hit a customer that needs them:

| Missing helper                          | Why we need it                                                                  |
|-----------------------------------------|---------------------------------------------------------------------------------|
| `runwhen-local.trustBundle.*`           | system CA bundle Secret overlay (analogue of `global.trustBundle` in platform; today only proxyCA-shaped overlay is supported) |
| `runwhen-local.scratchVolumes*`         | writable emptyDir for `readOnlyRootFilesystem: true` — currently disabled by default |
| `runwhen-local.podScheduling`           | standardise nodeSelector/tolerations/affinity emission across templates         |

When you ship one of these, run the verifier matrix and add a row to the
table above.

## Minimal "good citizen" template (Deployment)

Use this as the starting skeleton. Every helper invocation is mandatory;
the conditional `volumes:` / `volumeMounts:` blocks at the bottom are
mandatory when any of the optional mounts (proxyCA, scratch, etc.) can
turn on. See `templates/workspace-builder-deployment.yaml` for the
canonical first-party reference.

```yaml
{{- if .Values.myService.enabled }}
{{- $values := .Values.myService -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "runwhen-local.fullname" . }}-my-service
  labels:
    {{- include "runwhen-local.labels" . | nindent 4 }}
    app.kubernetes.io/component: my-service
spec:
  replicas: {{ $values.replicas | default 1 }}
  selector:
    matchLabels:
      {{- include "runwhen-local.selectorLabels" . | nindent 6 }}
      app.kubernetes.io/component: my-service
  template:
    metadata:
      labels:
        {{- include "runwhen-local.selectorLabels" . | nindent 8 }}
        app.kubernetes.io/component: my-service
        {{- include "runwhen-local.podLabels" . | nindent 8 }}
      {{- $podAnnotations := merge (deepCopy ($values.podAnnotations | default dict)) (deepCopy (.Values.podAnnotations | default dict)) }}
      {{- if $podAnnotations }}
      annotations:
        {{- range $k, $v := $podAnnotations }}
        {{ $k }}: {{ $v | quote }}
        {{- end }}
      {{- end }}
    spec:
      {{- include "runwhen-local.podSecurityContext" . | nindent 6 }}
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "runwhen-local.fullname" . }}-my-service
      automountServiceAccountToken: {{ $values.automountServiceAccountToken | default true }}
      containers:
        - name: my-service
          image: {{ include "runwhen-local.image" (list . $values.image "ghcr.io" "runwhen-contrib/my-service" .Chart.AppVersion) | quote }}
          imagePullPolicy: {{ $values.image.pullPolicy | default "IfNotPresent" }}
          {{- include "runwhen-local.containerSecurityContext" . | nindent 10 }}
          env:
            - name: SOMETHING
              value: "value"
            {{- if .Values.proxy.enabled }}
            {{- with .Values.proxy.httpProxy }}
            - name: HTTP_PROXY
              value: {{ . | quote }}
            {{- end }}
            {{- with .Values.proxy.httpsProxy }}
            - name: HTTPS_PROXY
              value: {{ . | quote }}
            {{- end }}
            {{- with .Values.proxy.noProxy }}
            - name: NO_PROXY
              value: {{ . | quote }}
            {{- end }}
            {{- end }}
            {{- /* trust-bundle env is decoupled from proxy.enabled */}}
            {{- include "runwhen-local.trustBundleEnv" . | nindent 12 }}
            {{- with $values.extraEnv }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
          ports:
            - containerPort: 8080
          {{- with $values.startupProbe }}
          startupProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $values.readinessProbe }}
          readinessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $values.livenessProbe }}
          livenessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          resources:
            {{- if eq .Values.platformType "EKS_Fargate" }}
            {{- toYaml ($values.resources.EKS_Fargate | default $values.resources.default) | nindent 12 }}
            {{- else }}
            {{- toYaml $values.resources.default | nindent 12 }}
            {{- end }}
          {{- if or .Values.proxyCA $values.volumeMounts }}
          volumeMounts:
            {{- if .Values.proxyCA }}
            - name: proxy-ca
              mountPath: /etc/ssl/certs/ca-certificates.crt
              subPath: ca-certificates.crt
            {{- end }}
            {{- with $values.volumeMounts }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
          {{- end }}
      {{- if or .Values.proxyCA $values.volumes }}
      volumes:
        {{- with .Values.proxyCA }}
        - name: proxy-ca
          {{- if .secretName }}
          secret:
            secretName: {{ .secretName }}
          {{- else if .configMapName }}
          configMap:
            name: {{ .configMapName }}
          {{- end }}
            items:
              - key: {{ .key | default "ca.crt" }}
                path: ca-certificates.crt
            defaultMode: 420
        {{- end }}
        {{- with $values.volumes }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      {{- end }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if or (eq .Values.platformArch "arm64") (not (empty .Values.tolerations)) (not (empty $values.tolerations)) }}
      tolerations:
        {{- if eq .Values.platformArch "arm64" }}
        - key: "kubernetes.io/arch"
          operator: "Equal"
          value: "arm64"
          effect: "NoSchedule"
        {{- end }}
        {{- with .Values.tolerations }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- with $values.tolerations }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      {{- end }}
{{- end }}
```

## values.yaml block — minimum shape

```yaml
# -- My service does <X>. Disabled by default; set enabled=true to enable.
myService:
  enabled: false
  replicas: 1
  image:
    registry: ""
    repository: ""
    tag: ""
    pullPolicy: IfNotPresent
  podAnnotations: {}
  extraEnv: []
  volumes: []
  volumeMounts: []
  tolerations: []
  resources:
    default:
      requests: { cpu: 50m, memory: 64Mi }
      limits:   { cpu: 200m, memory: 128Mi }
    EKS_Fargate:
      requests: { cpu: 200m, memory: 256Mi }
      limits:   { cpu: 200m, memory: 256Mi }
```

## Subchart matrix — `opentelemetry-collector`

The chart depends on `opentelemetry-collector` v0.129.0 (subchart-level
`condition: runner.enabled`). The OTel subchart renders its own
labels / annotations / podSecurityContext / image — top-level
`runwhen-local.*` knobs do NOT propagate to it.

### Knobs the subchart exposes (verified by rendering v0.129.0)

These are the subchart-level keys you can drive from the parent chart's
`opentelemetry-collector:` block (or via a customer overlay). Set them
EVERY TIME you add a corresponding "global" extension point upstream.

| Subchart key                                | Lands on                                                                  |
|---------------------------------------------|---------------------------------------------------------------------------|
| `additionalLabels`                          | every chart-rendered resource's `metadata.labels` (NOT pod template)      |
| `podLabels`                                 | pod template `metadata.labels` (admission webhooks key on these)          |
| `podAnnotations`                            | pod template `metadata.annotations` (sidecar inject, OPA, vault-agent)    |
| `podSecurityContext`                        | pod-level `spec.securityContext`                                          |
| `securityContext`                           | container-level `spec.containers[].securityContext`                       |
| `serviceAccount.{create,name,annotations}`  | own ServiceAccount + name override                                        |
| `serviceAccount.automountServiceAccountToken` | opt-out for OpenShift restricted-v2 / federal                           |
| `image.{repository,tag,pullPolicy,digest}`  | container image (full repo path — see registry note below)                |
| `imagePullSecrets`                          | pod-level pullSecrets list                                                |
| `nodeSelector` / `tolerations` / `affinity` | pod scheduling                                                            |
| `topologySpreadConstraints`                 | pod spread                                                                |
| `priorityClassName`                         | pod priority                                                              |
| `hostAliases`                               | `/etc/hosts` overrides                                                    |
| `extraEnvs` / `extraEnvsFrom`               | container env                                                             |
| `extraVolumes` / `extraVolumeMounts`        | additional pod volumes / mounts                                           |
| `extraContainers`                           | sidecars                                                                  |
| `resources`                                 | container resources                                                       |
| `replicaCount` / `revisionHistoryLimit`     | Deployment shape                                                          |
| `useGOMEMLIMIT`                             | auto-set GOMEMLIMIT to 80% of memory limit                                |

### Known gaps (no subchart knob — must be worked around)

- **No `image.registry` field.** The subchart accepts only a full
  `image.repository` path (e.g. `otel/opentelemetry-collector`). When a
  customer sets the parent chart's `.Values.registryOverride`, the
  override does NOT rewrite the OTel image. They must additionally pass
  `opentelemetry-collector.image.repository:
  <mirror>/otel/opentelemetry-collector` in their overlay. Document this
  in the customer-facing values block.
- **No `serviceAccount` fullname-prefix.** The parent chart's current
  `values.yaml` sets `serviceAccount.create: false` and
  `serviceAccount.name: "otel-collector"`. Two `runwhen-local` releases
  in the same namespace would share the SA — same release-collision
  class as the chart-managed runner SA. When that's fixed in the parent
  chart, mirror the change here.
- **No `commonLabels` global.** `additionalLabels` (resource-level) and
  `podLabels` (pod-template) are separate keys; if you ship a chart-wide
  `commonLabels` mechanism, drive BOTH from the same overlay.

### Anchor-and-alias overlay pattern (copy-paste-ready)

Customers running the chart with a corporate registry mirror, admission
labels, and Linkerd injection should layer their values like this — one
authoritative block at the top, anchor-aliased into both the parent
chart's surface AND the OTel subchart's:

```yaml
# values-corp.yaml ------------------------------------------------------
_byo: &byo
  commonLabels: &commonLabels
    cost-center: platform-eng
    compliance: pci
  podLabels: &podLabels
    policy/enforce: baseline
  podAnnotations: &podAnnotations
    linkerd.io/inject: enabled

# Parent chart (TODO once helpers exist) -------------------------------
# global:
#   commonLabels: *commonLabels
#   podLabels:    *podLabels
#   podAnnotations: *podAnnotations

# OpenTelemetry subchart -----------------------------------------------
opentelemetry-collector:
  additionalLabels: *commonLabels
  podLabels: *podLabels
  podAnnotations: *podAnnotations
  podSecurityContext:
    runAsNonRoot: true
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  serviceAccount:
    automountServiceAccountToken: false  # OpenShift restricted-v2
  image:
    # Subchart has NO image.registry knob — rewrite the full path.
    repository: artifactory.example.com/dockerhub/otel/opentelemetry-collector
    tag: "0.127.0"
  imagePullSecrets:
    - name: artifactory-pull
```

### Verify the subchart against the same matrix

The verifier accepts `opentelemetry-collector` as a target and runs a
slimmed Matrix-2/Matrix-3 against the subchart's Deployment using the
overlay-pattern values above:

```bash
.cursor/skills/new-service-byo/scripts/verify-service.sh \
  --subchart opentelemetry-collector
```

## Verify the template — one command

Run the verifier script over your new template:

```bash
.cursor/skills/new-service-byo/scripts/verify-service.sh \
  charts/runwhen-local/templates/<service>/<workload>.yaml
```

It renders the template under four matrices (defaults, `commonLabels`
attempted via `--set extraLabels`, proxy + proxyCA enabled,
`registryOverride`) and reports which checklist items rendered. Exit
code 0 = clean; non-zero = at least one missing knob.

## Tests — minimum 6 cases per service

Drop unit tests under `charts/runwhen-local/tests/<service>_test.yaml`
using `helm-unittest`. Each new service test file should include:

1. **Default render** — kind, name, component label, SA, restartPolicy
2. **Image resolution** — base case + `registryOverride` override + per-image override
3. **Resource-name prefixing** — name uses `runwhen-local.fullname` (two releases don't collide)
4. **Hardened SecurityContext** — `allowPrivilegeEscalation: false`,
   `capabilities.drop: [all]`, seccompProfile RuntimeDefault
5. **Proxy + proxyCA enabled** — env vars, volume, mount
6. **Opt-out path** — `<service>.enabled=false` (or `runner.enabled=false`)

Run with:

```bash
helm unittest charts/runwhen-local -f 'tests/my_service_test.yaml'
```

## Anti-patterns — never do these

| ❌ Don't                                                       | ✅ Do                                                                          |
|---------------------------------------------------------------|--------------------------------------------------------------------------------|
| Hardcode resource name (`runner`, `runner-relay`, `runner-role`) | `{{ include "runwhen-local.fullname" . }}-<suffix>` — collisions are silent  |
| Hardcode `serviceAccount: runner` in pod spec                  | resolve via a helper or `<service>.serviceAccount.name` value                  |
| Use a single bare label `app: runner` on chart resources       | `{{- include "runwhen-local.runnerLabels" . \| nindent 4 }}` (or wb variant)   |
| Hardcode the container image string                            | honour `registryOverride` + per-image `image.{registry,repository,tag}`        |
| Render `securityContext: {}` unconditionally                   | use the helper (it's render-or-nothing) — empty key triggers admission noise   |
| Render the same `securityContext:` key twice in one pod spec   | one block only — helper OR literal, never both (rejects on strict YAML parsers) |
| Skip the `<service>.enabled` gate                              | wrap the whole template in `{{- if .Values.<service>.enabled }}`               |
| Hardcode `automountServiceAccountToken: true`                  | accept an opt-out value (OpenShift restricted-v2 + federal customers)          |
| Bake `pullPolicy: Always` into the template                    | use `{{ $values.image.pullPolicy | default "IfNotPresent" }}`                  |
| Mount proxyCA only when `proxy.enabled` is true                | proxyCA is independently useful (corporate root CA on a non-proxied cluster); gate on `.Values.proxyCA` alone — see `runwhen-local.trustBundleEnv` |
| Empty `volumes:` / `volumeMounts:` keys (invalid YAML when conditionals off) | gate the whole `volumes:` block with `{{- if … }}`               |
| Skip the unit-test file                                        | always ship a `tests/<service>_test.yaml`                                      |

## Documented deferred gap — runner-control SA-name contract

The chart still defaults to bare resource names (`runner`,
`runner-relay`, `runner-role`, `runner-rolebinding`, `runner-config`,
`otel-collector*`, `workspace-builder*`) for back-compat with the
**runner-control** wire contract: runner-control-side code references
the SA named `runner` directly, and `.Values.runner.runEnvironment.{deployment,pod}.serviceAccount`
defaults to the literal `"runner"` so spawned CronCodeRun and TaskSet
workloads bind to the same SA.

The verifier flags every chart resource whose default name is not
release-prefixed; **those failures are expected** and persist until
runner-control supports SA-name override over the wire (tracked by the
TODO comment at the top of `templates/runner-service-account.yaml`).

### Multi-release operators — opt-in path

Operators who must run two `runwhen-local` releases in the same
namespace (or whose admission policies forbid bare resource names)
can override every collision-class name today via values:

```yaml
# values-rw2.yaml
runner:
  configMap:
    name: rw2-runner-config            # data + volume mount in the runner pod follow this
  serviceAccount:
    create: true
    name: rw2-runner                   # chart-rendered SA + Role + RoleBinding all follow this
  runEnvironment:
    deployment:
      serviceAccount: rw2-runner       # spawned CronCodeRun deployments
    pod:
      serviceAccount: rw2-runner       # spawned TaskSet pods
  otelCollector:
    serviceAccount:
      name: rw2-otel-collector         # parent-rendered OTel SA + Role + RoleBinding + ConfigMap

workspaceBuilder:
  serviceAccount:
    name: rw2-workspace-builder        # SA + Role + RoleBinding + Secret token
  workspaceInfo:
    configMap:
      name: rw2-workspace-builder      # ConfigMap consumed by the WB pod

# Subchart still has its own knob set — see the OpenTelemetry overlay
# pattern earlier in this file.
opentelemetry-collector:
  fullnameOverride: rw2-otel-collector
  serviceAccount:
    name: rw2-otel-collector
  configMap:
    existingName: rw2-otel-collector
```

### What the audit can / cannot see

When you run the verifier on a default-values render, the
"resource name is not release-prefixed" failure is the deferred
runner-control rename for the named templates above, **NOT** a
quality regression. Closing it requires a coordinated runner-control
update; do not attempt to flip the chart defaults in isolation.
