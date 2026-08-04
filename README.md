[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/runwhen-contrib)](https://artifacthub.io/packages/search?repo=runwhen-contrib)

# helm-charts

Public Helm charts for RunWhen platform components.

## Charts

### runwhen-local

<<<<<<< Updated upstream
<!-- START_TRIVY_SUMMARY -->
```
Registry                                                               Package                                  Vulnerability ID     Installed Version                         Fixed Version                 Severity
--------                                                               -------                                  ----------------     -----------------                         -------------                 --------
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    istio.io/istio                           CVE-2019-14993       v0.0.0-20260713165634-56df41f63e51+dirty  1.1.13, 1.2.4                 HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    istio.io/istio                           CVE-2021-39155       v0.0.0-20260713165634-56df41f63e51+dirty  1.9.8, 1.10.4, 1.11.1         HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    istio.io/istio                           CVE-2021-39156       v0.0.0-20260713165634-56df41f63e51+dirty  1.9.8, 1.10.4, 1.11.1         HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    istio.io/istio                           CVE-2022-23635       v0.0.0-20260713165634-56df41f63e51+dirty  1.13.1, 1.12.4, 1.11.7        HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    golang.org/x/net                         CVE-2026-25681       v0.49.0                                   0.55.0                        HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    Microsoft.NETCore.App.Runtime.linux-x64  CVE-2026-26127       9.0.10                                    9.0.14, 10.0.4                HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    System.Security.Cryptography.Xml         CVE-2026-26171       9.0.10                                    10.0.6, 9.0.15, 8.0.3         HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    golang.org/x/net                         CVE-2026-27136       v0.49.0                                   0.55.0                        HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    System.Security.Cryptography.Xml         CVE-2026-32203       9.0.10                                    10.0.6, 9.0.15, 8.0.3         HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    System.Security.Cryptography.Xml         CVE-2026-33116       9.0.10                                    10.0.6, 9.0.15, 8.0.3         HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    golang.org/x/net                         CVE-2026-33814       v0.49.0                                   0.53.0                        HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    github.com/docker/docker                 CVE-2026-34040       v28.5.2+incompatible                      29.3.1                        HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    golang.org/x/net                         CVE-2026-39821       v0.49.0                                   0.55.0                        HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    stdlib                                   CVE-2026-39822       v1.26.4                                   1.25.12, 1.26.5, 1.27.0-rc.2  HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    Microsoft.NETCore.App.Runtime.linux-x64  CVE-2026-47302       9.0.10                                    10.0.10, 9.0.18, 8.0.29       HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    System.Security.Cryptography.Xml         CVE-2026-47302       9.0.10                                    10.0.10, 9.0.18, 8.0.4        HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    System.Security.Cryptography.Xml         CVE-2026-47304       9.0.10                                    10.0.10, 9.0.18, 8.0.4        HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    Microsoft.NETCore.App.Runtime.linux-x64  CVE-2026-50524       9.0.10                                    10.0.10, 9.0.18, 8.0.29       HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    System.Security.Cryptography.Xml         CVE-2026-50525       9.0.10                                    10.0.10, 9.0.18, 8.0.4        HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    System.Security.Cryptography.Xml         CVE-2026-50527       9.0.10                                    10.0.10, 9.0.18, 8.0.4        HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    Microsoft.NETCore.App.Runtime.linux-x64  CVE-2026-50528       9.0.10                                    10.0.10, 9.0.18, 8.0.29       HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    System.Security.Cryptography.Xml         CVE-2026-50648       9.0.10                                    10.0.10, 9.0.18, 8.0.4        HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    Microsoft.NETCore.App.Runtime.linux-x64  CVE-2026-50651       9.0.10                                    10.0.10, 9.0.18, 8.0.29       HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    piscina                                  CVE-2026-55388       4.9.0                                     5.2.0, 4.9.3, 6.0.0-rc.2      HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    golang.org/x/text                        CVE-2026-56852       v0.33.0                                   0.39.0                        HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    golang.org/x/text                        CVE-2026-56852       v0.37.0                                   0.39.0                        HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    golang.org/x/text                        CVE-2026-56852       v0.38.0                                   0.39.0                        HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    Microsoft.NETCore.App.Runtime.linux-x64  CVE-2026-57108       9.0.10                                    10.0.10, 9.0.18, 8.0.29       HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    cryptography                             GHSA-537c-gmf6-5ccf  46.0.7                                    48.0.1                        HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    google.golang.org/grpc                   GHSA-hrxh-6v49-42gf  v1.81.1                                   1.82.1                        HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    google.golang.org/grpc                   GHSA-hrxh-6v49-42gf  v1.82.0                                   1.82.1                        HIGH
ghcr.io/runwhen-contrib/azure-c7n-codecollection:main-8c898ba-431db26  PyJWT                                    CVE-2026-48526       2.12.1                                    2.13.0                        HIGH
ghcr.io/runwhen-contrib/rw-public-codecollection:main-a4247b5-c08539c  System.Security.Cryptography.Xml         CVE-2026-47302       10.0.6                                    10.0.10, 9.0.18, 8.0.4        HIGH
ghcr.io/runwhen-contrib/rw-public-codecollection:main-a4247b5-c08539c  System.Security.Cryptography.Xml         CVE-2026-47304       10.0.6                                    10.0.10, 9.0.18, 8.0.4        HIGH
ghcr.io/runwhen-contrib/rw-public-codecollection:main-a4247b5-c08539c  System.Security.Cryptography.Xml         CVE-2026-50525       10.0.6                                    10.0.10, 9.0.18, 8.0.4        HIGH
ghcr.io/runwhen-contrib/rw-public-codecollection:main-a4247b5-c08539c  System.Security.Cryptography.Xml         CVE-2026-50527       10.0.6                                    10.0.10, 9.0.18, 8.0.4        HIGH
ghcr.io/runwhen-contrib/rw-public-codecollection:main-a4247b5-c08539c  System.Security.Cryptography.Xml         CVE-2026-50648       10.0.6                                    10.0.10, 9.0.18, 8.0.4        HIGH
otel/opentelemetry-collector:0.153.0                                   stdlib                                   CVE-2026-27145       v1.26.3                                   1.25.11, 1.26.4               HIGH
otel/opentelemetry-collector:0.153.0                                   stdlib                                   CVE-2026-39822       v1.26.3                                   1.25.12, 1.26.5, 1.27.0-rc.2  HIGH
otel/opentelemetry-collector:0.153.0                                   stdlib                                   CVE-2026-42504       v1.26.3                                   1.25.11, 1.26.4               HIGH
```
<!-- END_TRIVY_SUMMARY -->
=======
The `runwhen-local` Helm chart installs all client-side components into a Kubernetes cluster:
>>>>>>> Stashed changes

- **Automatic resource discovery** — detects and catalogs infrastructure resources
- **Automatic configuration** — tailors open source automation tasks to discovered resources
- **Frequent sync/upload** — pushes resources and configurations to the RunWhen Platform
- **Private task execution** — runs health checks and troubleshooting tasks (via alerts, Engineering Assistants, or on-demand)

<<<<<<< Updated upstream
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26
ghcr.io/runwhen-contrib/azure-c7n-codecollection:main-8c898ba-431db26
ghcr.io/runwhen-contrib/runwhen-local:0.11.8
ghcr.io/runwhen-contrib/rw-cli-codecollection:main-432f1d6-431db26
ghcr.io/runwhen-contrib/rw-generic-codecollection:main-9806414-431db26
ghcr.io/runwhen-contrib/rw-public-codecollection:main-a4247b5-c08539c
ghcr.io/runwhen-contrib/rw-workspace-utils:main-f3ef3ab-431db26
otel/opentelemetry-collector:0.153.0
us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner:2026-07-29.1
```
<!-- END_SCANNED_IMAGES -->
=======
See [charts/runwhen-local](charts/runwhen-local/) for installation instructions and configuration options.

## Security Scanning

Container images referenced by this chart are regularly scanned for CRITICAL and HIGH vulnerabilities using [Trivy](https://trivy.dev/latest/). Scan results are uploaded as workflow artifacts and can be reviewed in the [Trivy Scan for Critical Vulnerabilities](https://github.com/runwhen-contrib/helm-charts/actions/workflows/scanner.yaml) workflow runs.
>>>>>>> Stashed changes
