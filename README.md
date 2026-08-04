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

## Security Scanning

Container images referenced by this chart are scanned for CRITICAL and HIGH vulnerabilities using [Trivy](https://trivy.dev/latest/) on every PR, on a schedule, and on-demand. Results are uploaded as workflow artifacts — review the latest scan in the [Trivy Scan for Critical Vulnerabilities](https://github.com/runwhen-contrib/helm-charts/actions/workflows/scanner.yaml) workflow runs.
