# runwhen-local chart changelog

## 0.8.0

This release works with the dep-strip runwhen-runner images. Those images no
longer use runner-metric-proxy (Cortex/Mimir remote-write over mTLS) or
platform Vault.

### Changed defaults

| Value | Old default | New default |
|---|---|---|
| `runner.metrics.url` | `https://runner-cortex-tenant.beta.runwhen.com/push` | `""` |
| `runner.metrics.mtls.enabled` | `true` | `false` |
| `runner.metrics.otlp.keepCortex` | `true` | `false` |
| `opentelemetry-collector.extraVolumes` | `tls-secret-volume` (`{prefix}runner-metrics-tls`) | `[]` |
| `opentelemetry-collector.extraVolumeMounts` | `tls-secret-volume` at `/tls` | `[]` |

When `runner.metrics.url` is empty, the chart renders:

- no `prometheusremotewrite` (Cortex) exporter in the collector config;
- no `metricsAddr` in the runner config;
- no `runner-metrics-tls` volume, mount or Secret reference.

If OTLP metrics export (`runner.metrics.otlp`) is also off, the collector's
metrics pipelines use the built-in `nop` exporter, because a pipeline must have
at least one exporter. The OTLP metrics and logs export paths are unchanged.

### Deprecated

- `runner.metrics.url`, `runner.metrics.mtls`,
  `runner.metrics.otlp.keepCortex` and the
  `runwhen-local.runnerMetricsTls` helper (Cortex / runner-metric-proxy).
- Platform-Vault env vars (`RW_VAULT_*`, such as `RW_VAULT_ADDR_OVERRIDE`, and
  `VAULT_TOKEN_FILE`). The chart has never rendered these itself. They only
  appear when set through `runner.extraEnv`, and dep-strip runners ignore them.
  Secrets come from PAPI, and the runner defaults to `RW_SECRETS_SOURCE=papi`,
  so the chart does not set it.
- Customer secret providers (`runEnvironment.secretProviders`, `type: vault`)
  are **not** deprecated and are unchanged.

### Old values still render

No values were removed, and existing values files render without changes:

- Setting `runner.metrics.url` brings back the Cortex exporter and
  `metricsAddr` exactly as before. With OTLP enabled, Cortex is kept only if
  `keepCortex: true`.
- With `runner.metrics.mtls.enabled: true`, the exporter's `/tls` cert paths
  render as before. **Action required:** the TLS volume is no longer a chart
  default, so add it back in your values if you still use the Cortex mTLS
  path. Without it the collector cannot read `/tls/tls.crt` and does not start:

  ```yaml
  opentelemetry-collector:
    extraVolumes:
      - name: tls-secret-volume
        secret:
          secretName: '{{ include "runwhen-local.runnerMetricsTls" . }}'
    extraVolumeMounts:
      - name: tls-secret-volume
        mountPath: /tls
        readOnly: true
  ```

  Values files that already override `extraVolumes` / `extraVolumeMounts`
  (for example, to add a proxy CA) are unaffected.
- `RW_VAULT_*` / `VAULT_TOKEN_FILE` entries in `runner.extraEnv` are still
  passed through as before.
