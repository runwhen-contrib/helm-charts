# runwhen-runner

A private RunWhen **runner** and its bundled OpenTelemetry collector — no
workspace builder, no discovery. Split out of `runwhen-local` so a runner-only
deployment carries only the runner and its metrics path.

## What it deploys

- **runner** — `Deployment`, `ServiceAccount` + `Role`/`RoleBinding`, relay and
  metrics `Service`s, and the runner `ConfigMap`.
- **opentelemetry-collector** (subchart) — the metrics/logs collector, gated on
  `runner.enabled`.

## Runner configuration comes from the platform

A runner needs exactly one Secret, `{prefix}runner-registration-token`. It
resolves the rest from the platform:

- `runner-control` address — from the registration token's `runner_control_addr`
  claim (or `runner-creds.control_addr` after the first registration). Set
  `runner.controlAddr` only to override.
- `RW_PAPI_URL` and `RW_SECRETS_SOURCE=papi` — adopted from
  `GetRunnerConfig.upload_config.papi_url` and `/api/v1/runner/config`; the
  runner stamps them onto the worker/task pods it spawns.
- mTLS cert bundles, the workspace AppRole, the upload config, and the MCP
  stream address — delivered by `GetRunnerConfig`.

`runner.metrics.url` and `runner.codeCollections` remain chart values (they have
no platform source yet); `runner.metrics.url` defaults empty, in which case the
collector uses the `debug` exporter.

## Multi-release naming

`{prefix}` is the release name plus a dash (truncated to 32). Multiple releases
can share a namespace. `fullnameOverride` sets the Deployment/Service/ConfigMap
names independently.
