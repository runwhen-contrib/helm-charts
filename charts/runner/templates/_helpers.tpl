{{/*
Expand the name of the chart.
*/}}
{{- define "runner.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "runner.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "runner.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels — applied to every chart-rendered resource (Deployments,
Services, ConfigMaps, ServiceAccounts, RBAC, Ingresses).
Enterprise extension via `.Values.commonLabels` (admission webhooks,
FinOps tags, compliance markers). Selector labels are intentionally
separate from this — selectors are immutable post-create, so we never
let user labels into them.
*/}}
{{- define "runner.labels" -}}
helm.sh/chart: {{ include "runner.chart" . }}
{{ include "runner.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- range $k, $v := (.Values.commonLabels | default dict) }}
{{ $k }}: {{ $v | quote }}
{{- end }}
{{- end }}

{{/*
Selector labels (shared base) — kept lean and stable; never mixed with
user-supplied labels because spec.selector.matchLabels is immutable.
*/}}
{{- define "runner.selectorLabels" -}}
app.kubernetes.io/name: {{ include "runner.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Runner component labels and selectors
*/}}
{{- define "runner.runnerSelectorLabels" -}}
{{ include "runner.selectorLabels" . }}
app.kubernetes.io/component: runner
{{- end }}

{{- define "runner.runnerLabels" -}}
{{ include "runner.labels" . }}
app.kubernetes.io/component: runner
{{- end }}

{{/*
Pod-level extra labels — emits commonLabels + chart-wide podLabels +
per-service podLabels merged, with most-specific winning on conflicts.
Used under `.spec.template.metadata.labels`, AFTER the selector
labels. Render with `nindent 8`. No-op when all three maps are empty.

Accepts either the root context (chart-wide + commonLabels only) or a
list `(list . $serviceLabels)` where `$serviceLabels` is the per-service
overlay (e.g. `.Values.runner.podLabels`).

Precedence (most-specific wins): per-service > chart-wide > commonLabels.

Sprig `merge` semantics — DOCUMENTED HERE because Bugbot keeps misreading
the call. From the Sprig docs: "Merge two or more dictionaries into one,
giving precedence to the dest dictionary" — i.e. the FIRST argument
wins on conflict, regardless of how many sources follow. This is the
opposite of `mergeOverwrite`, which lets later args win.

Empirically verified with 3 args:
  $a := dict "k" "FIRST" }} {{ $b := dict "k" "SECOND" }} {{ $c := dict "k" "THIRD"
  (merge $a $b $c).k          → FIRST   ← what we want
  (mergeOverwrite $a $b $c).k → THIRD

So passing per-service first guarantees per-service wins.

Usage:
  # Chart-wide + commonLabels only:
  {{- include "runner.podLabels" . | nindent 8 }}

  # With per-service overlay:
  {{- include "runner.podLabels" (list . .Values.runner.podLabels) | nindent 8 }}
*/}}
{{- define "runner.podLabels" -}}
{{- $ctx := . -}}
{{- $extra := dict -}}
{{- if kindIs "slice" . -}}
  {{- $ctx = index . 0 -}}
  {{- $extra = (index . 1) | default dict -}}
{{- end -}}
{{- $labels := merge (deepCopy $extra) (deepCopy ($ctx.Values.podLabels | default dict)) (deepCopy ($ctx.Values.commonLabels | default dict)) -}}
{{- range $k, $v := $labels }}
{{ $k }}: {{ $v | quote }}
{{- end }}
{{- end }}

{{/*
Pod-level annotations — emits the `annotations:` keyword + chart-wide
`.Values.podAnnotations` when non-empty. Per-service annotations should
be emitted by the caller (after this) since YAML disallows duplicate
keys. No-op when the map is empty so we don't render an empty block.

Usage:
  template:
    metadata:
      labels: ...
      {{- include "runner.podAnnotations" . | nindent 6 }}
*/}}
{{- define "runner.podAnnotations" -}}
{{- with .Values.podAnnotations }}
annotations:
{{- range $k, $v := . }}
  {{ $k }}: {{ $v | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Image string resolver — single source of truth for `<registry>/<repo>:<tag>`.
Honours `.Values.registryOverride` when the per-image registry is empty.
Inputs (passed as a list):
  0 — root context (for .Values.registryOverride)
  1 — image dict (.registry, .repository, .tag)
  2 — fallback registry (string, used when neither image.registry nor registryOverride is set)
  3 — fallback repository (string)
  4 — fallback tag (string)

Usage:
  image: {{ include "runner.image" (list . $values.image "ghcr.io" "runwhen-contrib/foo" "latest") | quote }}
*/}}
{{- define "runner.image" -}}
{{- $ctx := index . 0 -}}
{{- $img := index . 1 -}}
{{- $defReg := index . 2 -}}
{{- $defRepo := index . 3 -}}
{{- $defTag := index . 4 -}}
{{- $registry := default ($ctx.Values.registryOverride) (default "" $img.registry) -}}
{{- if not $registry }}{{- $registry = $defReg -}}{{- end -}}
{{- $repository := default $defRepo (default "" $img.repository) -}}
{{- $tag := default $defTag (default "" $img.tag) -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- end }}

{{/*
Trust-bundle env vars — emit the standard 5 SSL/CA env entries when a
proxyCA (or future trustBundle) overlay is configured. Decoupled from
`.Values.proxy.enabled` because corporate root CAs are independently
useful on non-proxied clusters (private TLS, internal-only mTLS).

Accepts either the root context (checks `.Values.proxyCA`) or a list
`(list . $extra)` where `$extra` is an additional per-service overlay
(e.g. `$wb.proxyCA`). Renders when EITHER source is set, matching the
volume + volumeMount gating in the workspace-builder template.

Render under a container's `env:` list with `nindent 12` (deployment) or
`nindent 10` (workspace-builder). Render-or-nothing.

Usage:
  # Chart-wide proxyCA only:
  {{- include "runner.trustBundleEnv" . | nindent 12 }}

  # Chart-wide OR per-service overlay (workspace-builder):
  {{- include "runner.trustBundleEnv" (list . $wb.proxyCA) | nindent 10 }}
*/}}
{{- define "runner.trustBundleEnv" -}}
{{- $ctx := . -}}
{{- $extra := dict -}}
{{- if kindIs "slice" . -}}
  {{- $ctx = index . 0 -}}
  {{- $extra = (index . 1) | default dict -}}
{{- end -}}
{{- if or $ctx.Values.proxyCA $extra -}}
{{- $bundle := "/etc/ssl/certs/ca-certificates.crt" -}}
- name: SSL_CERT_FILE
  value: {{ $bundle | quote }}
- name: REQUESTS_CA_BUNDLE
  value: {{ $bundle | quote }}
- name: CURL_CA_BUNDLE
  value: {{ $bundle | quote }}
- name: NODE_EXTRA_CA_CERTS
  value: {{ $bundle | quote }}
- name: GIT_SSL_CAINFO
  value: {{ $bundle | quote }}
{{- end }}
{{- end }}

{{/*
Create the runner deployment name.
Truncate to 44 so the longest downstream suffix (-runner-rolebinding = 19 chars)
still fits within the 63-char Kubernetes DNS label limit.
*/}}
{{- define "runner.runnerFullname" -}}
{{- $full := include "runner.fullname" . | trunc 44 | trimSuffix "-" -}}
{{- if hasSuffix "-runner" $full -}}
{{- $full -}}
{{- else -}}
{{- printf "%s-runner" $full -}}
{{- end -}}
{{- end }}

{{/*
Release-name-derived prefix shared by every collision-class chart resource so
multiple releases can coexist in one namespace. Ends with "-" so callers compose
names as `{prefix}runner`, `{prefix}otel-collector`, `{prefix}uploadinfo`, etc.
Derived from .Release.Name alone -- deliberately NOT runner.fullname --
because the bundled opentelemetry-collector subchart cannot see the parent's
nameOverride/fullnameOverride, so a fullname-derived prefix would split the
parent-rendered names from the subchart's (and from the OTel TLS mount vs the
runner-written {prefix}runner-metrics-tls secret). Deployment names
(runnerFullname) are release-derived + trunc-44 and do NOT go through this
prefix.
*/}}
{{- define "runner.releasePrefix" -}}
{{- printf "%s-" (.Release.Name | trunc 32 | trimSuffix "-") -}}
{{- end }}

{{/*
Release-name-derived resource prefix used to disambiguate every
collision-class chart resource so multiple releases can coexist in the
same namespace. The prefix ends with a "-" so callers can compose names
as `{prefix}runner`, `{prefix}otel-collector`, `{prefix}uploadinfo`, etc.
The runner Deployment name (runnerFullname) is release-derived + trunc-44
by its own helper and does NOT go through this prefix.

Trunc-32 budget (63-char DNS label limit):
  32 (prefix, dash included) + longest suffix must be <= 63
  Longest composed names to plan for:
    runner-registration-token             (25 chars) → 32 + 25 = 57 ✓
    runner-workspace-secret               (23 chars) → 32 + 23 = 55 ✓
    runner-worker-<imageTag>              (14 + tag) — image tags are
      short (semver / date stamps), typically ≤ 16 chars, so 32 + 30 ≤ 63.

The wire contract with runwhen-runner also passes this string as the
`RUNNER_RESOURCE_PREFIX` env var so runner-created resources
(cert-bundle secrets, uploadinfo, runner-worker deployments, exec-*
pools, mcp-* deployments) match the chart-side names.
*/}}
{{- define "runner.resourcePrefix" -}}
{{- include "runner.releasePrefix" . }}
{{- end }}

{{/*
Resolve the runner ServiceAccount name. Defaults to the release-derived
{prefix}runner so multiple releases in one namespace never collide on the
runner SA. Operators can still pin an explicit name via
`.Values.runner.serviceAccount.name` (the documented escape hatch);
`serviceAccount.create: false` returns `default` if no name is supplied.

Usage:
  serviceAccountName: {{ include "runner.serviceAccountName.runner" . }}
*/}}
{{- define "runner.serviceAccountName.runner" -}}
{{- $sa := (.Values.runner.serviceAccount | default dict) -}}
{{- if hasKey $sa "create" | ternary $sa.create true }}
{{- default (printf "%srunner" (include "runner.resourcePrefix" .)) $sa.name }}
{{- else }}
{{- default "default" $sa.name }}
{{- end }}
{{- end }}

{{/*
Resolve the OpenTelemetry collector ServiceAccount name. The subchart
runs with `serviceAccount.create: false` and binds its Deployment to
`.Values."opentelemetry-collector".serviceAccount.name` — i.e. the
subchart is the SOURCE OF TRUTH for the SA name. The parent-chart's
ServiceAccount + Role + RoleBinding template MUST resolve to the same
name; otherwise a multi-release operator who renames via the subchart
key ends up with the subchart Deployment looking for one name while the
parent renders another — RBAC fails to bind.

Defaults to the release-derived {prefix}otel-collector so multiple
releases in one namespace never collide. Explicit
`opentelemetry-collector.serviceAccount.name` still wins (it MUST be
the subchart key so both layers agree). See the parent-side otel
deployment template for how the subchart Deployment renders through
the augmented values context so this default is honoured end-to-end.
*/}}
{{- define "runner.serviceAccountName.otelCollector" -}}
{{- $subchart := index .Values "opentelemetry-collector" | default dict -}}
{{- $sa := ($subchart.serviceAccount | default dict) -}}
{{- default (printf "%sotel-collector" (include "runner.otelSubchartPrefix" .)) $sa.name }}
{{- end }}

{{/*
Resolve the OpenTelemetry collector ConfigMap name. Same coupling
shape as the SA helper above: the subchart runs with
`configMap.create: false` + `configMap.existingName: "otel-collector"`
and the subchart Deployment mounts that ConfigMap by name. The
parent-chart's ConfigMap template renders the actual relay config, so
its name MUST equal `.Values."opentelemetry-collector".configMap.existingName`
or the collector pod gets stuck in `CreateContainerConfigError`.

Defaults to the release-derived {prefix}otel-collector. Override via
`opentelemetry-collector.configMap.existingName` to pin an explicit
name.
*/}}
{{- define "runner.configMapName.otelCollector" -}}
{{- $subchart := index .Values "opentelemetry-collector" | default dict -}}
{{- $cm := ($subchart.configMap | default dict) -}}
{{- if $cm.existingName -}}
{{- tpl (toString $cm.existingName) . }}
{{- else -}}
{{- printf "%sotel-collector" (include "runner.otelSubchartPrefix" .) }}
{{- end -}}
{{- end }}

{{/*
Resolve the OpenTelemetry collector Service name from the PARENT chart
scope. The subchart's Service (templates/service.yaml) is named by
`opentelemetry-collector.fullname`, which the parent shadows below so the
name is release-derived by default. That shadow helper reads
`.Values.fullnameOverride`, and when it is invoked from a parent template
that key is the ROOT fullnameOverride -- not the subchart's -- so calling
it here would miss an operator's `opentelemetry-collector.fullnameOverride`.
This helper reads the subchart-scoped key explicitly (the same rule the
subchart's own Service renders with) so a runner's OTLP env can never
point at a Service name that does not exist. Mirrors
runner.serviceAccountName.otelCollector and
runner.configMapName.otelCollector.
*/}}
{{- define "runner.otelCollectorServiceName" -}}
{{- $subchart := index .Values "opentelemetry-collector" | default dict -}}
{{- if $subchart.fullnameOverride -}}
{{- $subchart.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%sotel-collector" (include "runner.otelSubchartPrefix" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end }}

{{/*
Release-derived prefix for the bundled `opentelemetry-collector`
subchart. Alias of `runner.releasePrefix`, kept as its own name so
call sites state their intent (subchart coupling) and so a future
subchart-specific need has a seam. See `runner.releasePrefix` for
why the derivation is release-only and shared with the parent-side
resource prefix: it is what keeps the subchart's shadowed Deployment /
Service / ConfigMap / SA names aligned with the parent-rendered
otel-collector SA, ConfigMap and RBAC even when nameOverride or
fullnameOverride is set.
*/}}
{{- define "runner.otelSubchartPrefix" -}}
{{- include "runner.releasePrefix" . }}
{{- end }}

{{/*
Shadow the subchart's `opentelemetry-collector.fullname` so the subchart
Deployment/Service/other names are release-derived by default. Maintains
fullnameOverride as the explicit escape hatch. Rendered in subchart context.
*/}}
{{- define "opentelemetry-collector.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%sotel-collector" (include "runner.otelSubchartPrefix" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end }}

{{/*
Shadow the subchart's `opentelemetry-collector.serviceAccountName` so the
subchart Deployment binds the release-derived {prefix}otel-collector SA by
default. Honors an explicit `.Values.serviceAccount.name`. Rendered in
subchart context. `serviceAccount` is nil-guarded because a values overlay
that sets `opentelemetry-collector.serviceAccount: null` must still render,
not fail with a nil-pointer error.
*/}}
{{- define "opentelemetry-collector.serviceAccountName" -}}
{{- $sa := (.Values.serviceAccount | default dict) -}}
{{- if $sa.name -}}
{{- $sa.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%sotel-collector" (include "runner.otelSubchartPrefix" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end }}

{{/*
Release-derived name of the mTLS cert-bundle Secret the OTel collector
mounts (see `runner.metrics.mtls`). Matches the `{prefix}runner-metrics-tls`
name written by a prefix-aware runner. Used in the subchart's
`extraVolumes[].secret.secretName`, which the subchart tpl-renders.
*/}}
{{- define "runner.runnerMetricsTls" -}}
{{- printf "%srunner-metrics-tls" (include "runner.otelSubchartPrefix" .) -}}
{{- end }}

{{/*
Exporter list for the runner metrics pipelines. Kept in sync with the
exporter definitions in runner-otel-collector-configmap.yaml.

Includes the Cortex `prometheusremotewrite` exporter unless the install
has opted to cut over via `runner.metrics.otlp.keepCortex=false`, and
appends the opt-in OTLP exporter (`otlphttp/runwhen` for http/protobuf,
`otlp/runwhen` for grpc) when `runner.metrics.otlp.enabled=true`.
*/}}
{{- define "runner.runnerMetricsExporters" -}}
{{- $metrics := .Values.runner.metrics | default dict -}}
{{- $otlp := $metrics.otlp | default dict -}}
{{- $exporters := list -}}
{{- if and $metrics.url (or (not $otlp.enabled) $otlp.keepCortex) -}}
{{- $exporters = append $exporters "prometheusremotewrite" -}}
{{- end -}}
{{- if $otlp.enabled -}}
{{- if eq (default "http/protobuf" $otlp.protocol) "grpc" -}}
{{- $exporters = append $exporters "otlp/runwhen" -}}
{{- else -}}
{{- $exporters = append $exporters "otlphttp/runwhen" -}}
{{- end -}}
{{- end -}}
{{- if eq (len $exporters) 0 -}}
{{- $exporters = append $exporters "debug" -}}
{{- end -}}
{{- join ", " $exporters -}}
{{- end }}

{{/*
Exporter list for the runner logs pipeline. Sibling of
`runner.runnerMetricsExporters`; kept in sync with the exporter
definitions in runner-otel-collector-configmap.yaml.

Logs are an independent opt-in from metrics (`runner.logs.otlp.enabled`)
with their own endpoint/protocol/headers, so the logs exporter is a
distinct instance — `otlphttp/runwhen-logs` for http/protobuf,
`otlp/runwhen-logs` for grpc — rather than sharing the metrics exporter.
Sharing would force the two signals onto one protocol and one base
endpoint; the sibling keeps them decoupled while mirroring the metrics
helper's shape. Returns an empty string when disabled so the configmap
can gate the `logs` pipeline on it.
*/}}
{{- define "runner.runnerLogsExporters" -}}
{{- $otlp := .Values.runner.logs.otlp | default dict -}}
{{- if $otlp.enabled -}}
{{- if eq (default "http/protobuf" $otlp.protocol) "grpc" -}}
otlp/runwhen-logs
{{- else -}}
otlphttp/runwhen-logs
{{- end -}}
{{- end -}}
{{- end }}

{{/*
Standard OpenTelemetry env that points a runner/worker process at THIS
release's bundled OTel collector for LOGS. Emitted only when
`runner.logs.otlp.enabled=true`, so with the flag off (the default) the
consumer pod spec renders byte-identically to a chart without this feature.

The endpoint ALWAYS targets the in-cluster collector Service resolved by
`runner.otelCollectorServiceName`; the collector owns the onward
forward (to OpenObserve, or whatever `runner.logs.otlp.endpoint` names).
The pod therefore never needs to know the final destination, and an
external or per-signal logs endpoint does not change the pod env.

protocol: http/protobuf (the default) -> http://<collector>:4318/v1/logs
          grpc                         -> <collector>:4317 (no path; the
          runner's gRPC exporter accepts a bare host:port)

Inputs (list):
  0  root context
  1  OTEL_SERVICE_NAME for this component (empty omits the variable)
  2  the container's already-configured env entries (usually the user's
     extraEnv); any of our variable names present there is skipped, so an
     explicit operator value wins and no duplicate key is emitted.

Rendered under a container's `env:` list with `nindent 12`.
*/}}
{{- define "runner.runnerOtlpLogsEnv" -}}
{{- $ctx := index . 0 -}}
{{- $serviceName := index . 1 -}}
{{- $extra := index . 2 | default list -}}
{{- $logsOtlp := $ctx.Values.runner.logs.otlp | default dict -}}
{{- if $logsOtlp.enabled -}}
{{- $protocol := default "http/protobuf" $logsOtlp.protocol -}}
{{- $collector := include "runner.otelCollectorServiceName" $ctx -}}
{{- $endpoint := printf "http://%s:4318/v1/logs" $collector -}}
{{- if eq $protocol "grpc" -}}
{{- $endpoint = printf "%s:4317" $collector -}}
{{- end -}}
{{- $existing := dict -}}
{{- range $extra -}}
{{- if kindIs "map" . -}}
{{- if .name -}}{{- $_ := set $existing .name true -}}{{- end -}}
{{- end -}}
{{- end -}}
{{- if not (hasKey $existing "OTEL_EXPORTER_OTLP_LOGS_ENDPOINT") }}
- name: OTEL_EXPORTER_OTLP_LOGS_ENDPOINT
  value: {{ $endpoint | quote }}
{{- end }}
{{- if not (hasKey $existing "OTEL_EXPORTER_OTLP_PROTOCOL") }}
- name: OTEL_EXPORTER_OTLP_PROTOCOL
  value: {{ $protocol | quote }}
{{- end }}
{{- if not (hasKey $existing "OTEL_LOGS_EXPORTER") }}
- name: OTEL_LOGS_EXPORTER
  value: "otlp"
{{- end }}
{{- if and $serviceName (not (hasKey $existing "OTEL_SERVICE_NAME")) }}
- name: OTEL_SERVICE_NAME
  value: {{ $serviceName | quote }}
{{- end }}
{{- end -}}
{{- end }}

{{/*
Set Global Security Context
*/}}
{{- define "runner.containerSecurityContext" -}}
{{- if .Values.containerSecurityContext }}
securityContext:
{{ toYaml .Values.containerSecurityContext | indent 2 }}
{{- end }}
{{- end }}

{{- define "runner.podSecurityContext" -}}
{{- if .Values.podSecurityContext }}
securityContext:
{{ toYaml .Values.podSecurityContext | indent 2 }}
{{- end }}
{{- end }}