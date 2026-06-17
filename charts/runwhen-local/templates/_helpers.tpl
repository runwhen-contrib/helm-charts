{{/*
Expand the name of the chart.
*/}}
{{- define "runwhen-local.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "runwhen-local.fullname" -}}
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
{{- define "runwhen-local.chart" -}}
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
{{- define "runwhen-local.labels" -}}
helm.sh/chart: {{ include "runwhen-local.chart" . }}
{{ include "runwhen-local.selectorLabels" . }}
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
{{- define "runwhen-local.selectorLabels" -}}
app.kubernetes.io/name: {{ include "runwhen-local.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Workspace-builder component labels and selectors.
app.kubernetes.io/name uses the workspace-builder fullname (e.g. runwhen-local-workspace-builder).
*/}}
{{- define "runwhen-local.workspaceBuilderSelectorLabels" -}}
app.kubernetes.io/name: {{ include "runwhen-local.workspaceBuilderFullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: workspace-builder
{{- end }}

{{- define "runwhen-local.workspaceBuilderLabels" -}}
helm.sh/chart: {{ include "runwhen-local.chart" . }}
{{ include "runwhen-local.workspaceBuilderSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- range $k, $v := (.Values.commonLabels | default dict) }}
{{ $k }}: {{ $v | quote }}
{{- end }}
{{- end }}

{{/*
Runner component labels and selectors
*/}}
{{- define "runwhen-local.runnerSelectorLabels" -}}
{{ include "runwhen-local.selectorLabels" . }}
app.kubernetes.io/component: runner
{{- end }}

{{- define "runwhen-local.runnerLabels" -}}
{{ include "runwhen-local.labels" . }}
app.kubernetes.io/component: runner
{{- end }}

{{/*
Pod-level extra labels — emits commonLabels + podLabels merged. Used
under `.spec.template.metadata.labels`, AFTER the selector labels.
Render with `nindent 8`. No-op when both maps are empty.

Usage:
  template:
    metadata:
      labels:
        {{- include "runwhen-local.runnerSelectorLabels" . | nindent 8 }}
        {{- include "runwhen-local.podLabels" . | nindent 8 }}
*/}}
{{- define "runwhen-local.podLabels" -}}
{{- $labels := merge (deepCopy (.Values.podLabels | default dict)) (deepCopy (.Values.commonLabels | default dict)) -}}
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
      {{- include "runwhen-local.podAnnotations" . | nindent 6 }}
*/}}
{{- define "runwhen-local.podAnnotations" -}}
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
  image: {{ include "runwhen-local.image" (list . $values.image "ghcr.io" "runwhen-contrib/foo" "latest") | quote }}
*/}}
{{- define "runwhen-local.image" -}}
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

Render under a container's `env:` list with `nindent 12` (deployment) or
`nindent 10` (workspace-builder). Render-or-nothing.

Usage:
          env:
            - name: SOMETHING
              value: "x"
            {{- include "runwhen-local.trustBundleEnv" . | nindent 12 }}
*/}}
{{- define "runwhen-local.trustBundleEnv" -}}
{{- if .Values.proxyCA -}}
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
Resolve workspace builder values with backward compatibility.
DEPRECATED: Support for the old "runwhenLocal" values key.
  If a user's values file still uses "runwhenLocal:", those values are merged
  over the "workspaceBuilder:" defaults so existing installs keep working.
  Remove this fallback once all consumers have migrated to "workspaceBuilder:".
*/}}
{{- define "runwhen-local.resolveWorkspaceBuilder" -}}
{{- if .Values.runwhenLocal -}}
{{- mergeOverwrite (deepCopy .Values.workspaceBuilder) .Values.runwhenLocal | toYaml -}}
{{- else -}}
{{- .Values.workspaceBuilder | toYaml -}}
{{- end -}}
{{- end -}}

{{/*
Create the workspace-builder deployment name.
*/}}
{{- define "runwhen-local.workspaceBuilderFullname" -}}
{{- printf "%s-workspace-builder" (include "runwhen-local.fullname" . | trunc 44 | trimSuffix "-") }}
{{- end }}

{{/*
Create the runner deployment name.
Truncate to 44 so the longest downstream suffix (-runner-rolebinding = 19 chars)
still fits within the 63-char Kubernetes DNS label limit.
*/}}
{{- define "runwhen-local.runnerFullname" -}}
{{- printf "%s-runner" (include "runwhen-local.fullname" . | trunc 44 | trimSuffix "-") }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "runwhen-local.serviceAccountName" -}}
{{- $wb := include "runwhen-local.resolveWorkspaceBuilder" . | fromYaml -}}
{{- if $wb.serviceAccount.create }}
{{- default (include "runwhen-local.fullname" .) $wb.serviceAccount.name }}
{{- else }}
{{- default "default" $wb.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Resolve the runner ServiceAccount name. Defaults to the literal "runner"
for back-compat with existing installs and the runner-control wire
contract (see TODOs in runner-* templates). Operators with multi-release
namespaces or admission policies that forbid bare names can override via
`.Values.runner.serviceAccount.name`. Honours `serviceAccount.create=false`
(returns `default` if no name is supplied).

Usage:
  serviceAccountName: {{ include "runwhen-local.serviceAccountName.runner" . }}
*/}}
{{- define "runwhen-local.serviceAccountName.runner" -}}
{{- $sa := (.Values.runner.serviceAccount | default dict) -}}
{{- if hasKey $sa "create" | ternary $sa.create true }}
{{- default "runner" $sa.name }}
{{- else }}
{{- default "default" $sa.name }}
{{- end }}
{{- end }}

{{/*
Resolve the OpenTelemetry collector ServiceAccount name (referenced by
the parent-chart-rendered SA / RoleBinding and consumed by the OTel
subchart via `opentelemetry-collector.serviceAccount.name`). Defaults to
the literal "otel-collector" for back-compat. Override via
`.Values.runner.otelCollector.serviceAccount.name` when a multi-release
namespace forces a unique name.
*/}}
{{- define "runwhen-local.serviceAccountName.otelCollector" -}}
{{- $otel := (((.Values.runner).otelCollector) | default dict) -}}
{{- $sa := ($otel.serviceAccount | default dict) -}}
{{- default "otel-collector" $sa.name }}
{{- end }}

{{/*
Reuse workspacename.
*/}}
{{- define "runwhen-local.workspaceName" -}}
{{ .Values.workspaceName }}
{{- end -}}

{{/*
Set Global Security Context
*/}}
{{- define "runwhen-local.containerSecurityContext" -}}
{{- if .Values.containerSecurityContext }}
securityContext:
{{ toYaml .Values.containerSecurityContext | indent 2 }}
{{- end }}
{{- end }}

{{- define "runwhen-local.podSecurityContext" -}}
{{- if .Values.podSecurityContext }}
securityContext:
{{ toYaml .Values.podSecurityContext | indent 2 }}
{{- end }}
{{- end }}