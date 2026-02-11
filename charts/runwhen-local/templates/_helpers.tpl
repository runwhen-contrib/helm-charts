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
Common labels
*/}}
{{- define "runwhen-local.labels" -}}
helm.sh/chart: {{ include "runwhen-local.chart" . }}
{{ include "runwhen-local.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "runwhen-local.selectorLabels" -}}
app.kubernetes.io/name: {{ include "runwhen-local.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
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