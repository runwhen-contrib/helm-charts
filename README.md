[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/runwhen-contrib)](https://artifacthub.io/packages/search?repo=runwhen-contrib)

# helm-charts

Helm charts for RunWhen's open-source and community components.

## Charts

| Chart | Description | Docs |
|---|---|---|
| [`charts/runwhen-local`](charts/runwhen-local/) | Deploys the RunWhen Local workspace builder, runner, and workers — private discovery and task execution inside your Kubernetes cluster. | [`README`](charts/runwhen-local/README.md) · [`values.yaml`](charts/runwhen-local/values.yaml) |

## Quickstart

```console
helm repo add runwhen-contrib https://runwhen-contrib.github.io/helm-charts
helm repo update
helm install my-runwhen runwhen-contrib/runwhen-local -n runwhen-local --create-namespace
```

See the [chart README](charts/runwhen-local/README.md) for full configuration, prerequisites, and troubleshooting.

## Log Levels

The workspace builder supports granular log level control via environment variables. Each module (indexers, enrichers, renderers, core) can be set independently, or you can toggle debug logging globally.

### Quick toggle

Enable debug logging for all workspace builder modules:

```console
helm install my-runwhen runwhen-contrib/runwhen-local \
  --set workspaceBuilder.debugLogs=true
```

This sets `DEBUG_LOGGING=true`, which overrides all per-module levels to `DEBUG`.

### Per-module log levels

For finer control, use `workspaceBuilder.extraEnv` to set specific modules. All values default to `INFO`.

```yaml
workspaceBuilder:
  extraEnv:
    - name: LOG_LEVEL_ROOT
      value: "INFO"
    - name: LOG_LEVEL_INDEXERS
      value: "DEBUG"
    - name: LOG_LEVEL_ENRICHERS
      value: "DEBUG"
    - name: LOG_LEVEL_RENDERERS
      value: "INFO"
    - name: LOG_LEVEL_WORKSPACE_BUILDER
      value: "INFO"
```

Available variables:

| Variable | Controls | Default |
|---|---|---|
| `LOG_LEVEL_ROOT` | All modules (fallback) | `INFO` |
| `LOG_LEVEL_INDEXERS` | Resource discovery indexers | `LOG_LEVEL_ROOT` |
| `LOG_LEVEL_ENRICHERS` | Resource enrichment | `LOG_LEVEL_ROOT` |
| `LOG_LEVEL_RENDERERS` | Output rendering | `LOG_LEVEL_ROOT` |
| `LOG_LEVEL_WORKSPACE_BUILDER` | Workspace builder core | `LOG_LEVEL_ROOT` |
| `LOG_FORMAT` | Console output: `json` or `simple` | `json` |
| `DEBUG_LOGGING` | Set all modules to `DEBUG` | `false` |

### Runner log level

Runner debug logging is controlled separately:

```yaml
runner:
  debugLogs: true    # sets RUNNER_LOG_LEVEL=DEBUG
  log:
    level: info      # default runner log level
```

## Security Scanning

Container images referenced by this chart are scanned for CRITICAL and HIGH vulnerabilities using [Trivy](https://trivy.dev/latest/) on every PR, on a schedule, and on-demand. Results are uploaded as workflow artifacts — review the latest scan in the [Trivy Scan for Critical Vulnerabilities](https://github.com/runwhen-contrib/helm-charts/actions/workflows/scanner.yaml) workflow runs.
