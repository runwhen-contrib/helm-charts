[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/runwhen-contrib)](https://artifacthub.io/packages/search?repo=runwhen-contrib)

# helm-charts
All Public RunWhen Helm Charts 

## RunWhen Local
The `runwhen-local` helm chart is responsible for installing all client-side components into a Kuberetes cluster. These components perform: 
- automatic resource discovery
- automatic configuration (tailoring open source automation tasks for all discovered resources)
- frequent sync/upload of resources and configurations to the RunWhen Platform
- private execution of health and troubleshooting tasks (via. alerts, Engineering Assistatents, or on-demand)

## Latest Security Scan Results
Security scans regularly run against all images used by this helm chart using [trivy](https://trivy.dev/latest/), scanning for CRITICAL and HIGH vulnerabilities that are fixable. 

```
trivy image --severity CRITICAL,HIGH --ignore-unfixed --scanners vuln --format json "$registry" > trivy_result.json
```

<!-- START_TRIVY_SUMMARY -->
```
Registry                                                               Package                                  Vulnerability ID     Installed Version                         Fixed Version                      Severity
--------                                                               -------                                  ----------------     -----------------                         -------------                      --------
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    istio.io/istio                           CVE-2019-14993       v0.0.0-20260713165634-56df41f63e51+dirty  1.1.13, 1.2.4                      HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    istio.io/istio                           CVE-2021-39155       v0.0.0-20260713165634-56df41f63e51+dirty  1.9.8, 1.10.4, 1.11.1              HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    istio.io/istio                           CVE-2021-39156       v0.0.0-20260713165634-56df41f63e51+dirty  1.9.8, 1.10.4, 1.11.1              HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    istio.io/istio                           CVE-2022-23635       v0.0.0-20260713165634-56df41f63e51+dirty  1.13.1, 1.12.4, 1.11.7             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    golang.org/x/net                         CVE-2026-25681       v0.49.0                                   0.55.0                             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    Microsoft.NETCore.App.Runtime.linux-x64  CVE-2026-26127       9.0.10                                    9.0.14, 10.0.4                     HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    System.Security.Cryptography.Xml         CVE-2026-26171       9.0.10                                    10.0.6, 9.0.15, 8.0.3              HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    golang.org/x/net                         CVE-2026-27136       v0.49.0                                   0.55.0                             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    System.Security.Cryptography.Xml         CVE-2026-32203       9.0.10                                    10.0.6, 9.0.15, 8.0.3              HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    System.Security.Cryptography.Xml         CVE-2026-33116       9.0.10                                    10.0.6, 9.0.15, 8.0.3              HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    golang.org/x/net                         CVE-2026-33814       v0.49.0                                   0.53.0                             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    github.com/docker/docker                 CVE-2026-34040       v28.5.2+incompatible                      29.3.1                             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    golang.org/x/net                         CVE-2026-39821       v0.49.0                                   0.55.0                             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    stdlib                                   CVE-2026-39822       v1.26.4                                   1.25.12, 1.26.5, 1.27.0-rc.2       HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    Microsoft.NETCore.App.Runtime.linux-x64  CVE-2026-47302       9.0.10                                    10.0.10, 9.0.18, 8.0.29            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    System.Security.Cryptography.Xml         CVE-2026-47302       9.0.10                                    10.0.10, 9.0.18, 8.0.4             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    System.Security.Cryptography.Xml         CVE-2026-47304       9.0.10                                    10.0.10, 9.0.18, 8.0.4             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    Microsoft.NETCore.App.Runtime.linux-x64  CVE-2026-50524       9.0.10                                    10.0.10, 9.0.18, 8.0.29            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    System.Security.Cryptography.Xml         CVE-2026-50525       9.0.10                                    10.0.10, 9.0.18, 8.0.4             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    System.Security.Cryptography.Xml         CVE-2026-50527       9.0.10                                    10.0.10, 9.0.18, 8.0.4             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    Microsoft.NETCore.App.Runtime.linux-x64  CVE-2026-50528       9.0.10                                    10.0.10, 9.0.18, 8.0.29            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    System.Security.Cryptography.Xml         CVE-2026-50648       9.0.10                                    10.0.10, 9.0.18, 8.0.4             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    Microsoft.NETCore.App.Runtime.linux-x64  CVE-2026-50651       9.0.10                                    10.0.10, 9.0.18, 8.0.29            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    piscina                                  CVE-2026-55388       4.9.0                                     5.2.0, 4.9.3, 6.0.0-rc.2           HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    golang.org/x/text                        CVE-2026-56852       v0.33.0                                   0.39.0                             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    golang.org/x/text                        CVE-2026-56852       v0.37.0                                   0.39.0                             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    golang.org/x/text                        CVE-2026-56852       v0.38.0                                   0.39.0                             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    Microsoft.NETCore.App.Runtime.linux-x64  CVE-2026-57108       9.0.10                                    10.0.10, 9.0.18, 8.0.29            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    cryptography                             GHSA-537c-gmf6-5ccf  46.0.7                                    48.0.1                             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    google.golang.org/grpc                   GHSA-hrxh-6v49-42gf  v1.81.1                                   1.82.1                             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-4348a20-431db26    google.golang.org/grpc                   GHSA-hrxh-6v49-42gf  v1.82.0                                   1.82.1                             HIGH
ghcr.io/runwhen-contrib/azure-c7n-codecollection:main-8c898ba-431db26  PyJWT                                    CVE-2026-48526       2.12.1                                    2.13.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2023-39325       v1.21.1                                   1.20.10, 1.21.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2023-45283       v1.21.1                                   1.20.11, 1.21.4, 1.20.12, 1.21.5   HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/net                         CVE-2023-45288       v0.17.0                                   0.23.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/net                         CVE-2023-45288       v0.19.0                                   0.23.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2023-45288       v1.21.1                                   1.21.9, 1.22.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2024-24790       v1.21.1                                   1.21.11, 1.22.4                    CRITICAL
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2024-34156       v1.21.1                                   1.22.7, 1.23.1                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2024-45337       v0.14.0                                   0.31.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2024-45337       v0.17.0                                   0.31.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/net                         CVE-2024-45338       v0.17.0                                   0.33.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/net                         CVE-2024-45338       v0.19.0                                   0.33.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/oauth2                      CVE-2025-22868       v0.13.0                                   0.27.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2025-22869       v0.14.0                                   0.35.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2025-22869       v0.17.0                                   0.35.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2025-22874       v1.24.1                                   1.24.4                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           github.com/golang-jwt/jwt/v4             CVE-2025-30204       v4.5.0                                    4.5.2                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           setuptools                               CVE-2025-47273       70.3.0                                    78.1.1                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2025-47913       v0.14.0                                   0.43.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2025-47913       v0.17.0                                   0.43.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2025-61726       v1.21.1                                   1.24.12, 1.25.6                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2025-61726       v1.22.12                                  1.24.12, 1.25.6                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2025-61726       v1.24.1                                   1.24.12, 1.25.6                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2025-61726       v1.25.5                                   1.24.12, 1.25.6                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2025-61729       v1.21.1                                   1.24.11, 1.25.5                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2025-61729       v1.22.12                                  1.24.11, 1.25.5                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2025-61729       v1.24.1                                   1.24.11, 1.25.5                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           starlette                                CVE-2025-62727       0.46.2                                    0.49.1                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           urllib3                                  CVE-2025-66418       2.3.0                                     2.6.0                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           urllib3                                  CVE-2025-66471       2.3.0                                     2.6.0                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2025-68121       v1.21.1                                   1.24.13, 1.25.7, 1.26.0-rc.3       CRITICAL
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2025-68121       v1.22.12                                  1.24.13, 1.25.7, 1.26.0-rc.3       CRITICAL
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2025-68121       v1.24.1                                   1.24.13, 1.25.7, 1.26.0-rc.3       CRITICAL
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2025-68121       v1.25.5                                   1.24.13, 1.25.7, 1.26.0-rc.3       CRITICAL
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           undici                                   CVE-2026-12151       6.26.0                                    6.27.0, 7.28.0, 8.5.0              HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           brace-expansion                          CVE-2026-13149       5.0.6                                     5.0.7, 1.1.16, 2.1.2               HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           brace-expansion                          CVE-2026-14257       5.0.6                                     5.0.8                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           urllib3                                  CVE-2026-21441       2.3.0                                     2.6.3                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-25679       v1.21.1                                   1.25.8, 1.26.1                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-25679       v1.22.12                                  1.25.8, 1.26.1                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-25679       v1.24.1                                   1.25.8, 1.26.1                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-25679       v1.25.5                                   1.25.8, 1.26.1                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/net                         CVE-2026-25681       v0.17.0                                   0.55.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/net                         CVE-2026-25681       v0.19.0                                   0.55.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/net                         CVE-2026-25681       v0.37.0                                   0.55.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/net                         CVE-2026-25681       v0.47.0                                   0.55.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/net                         CVE-2026-27136       v0.17.0                                   0.55.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/net                         CVE-2026-27136       v0.19.0                                   0.55.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/net                         CVE-2026-27136       v0.37.0                                   0.55.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/net                         CVE-2026-27136       v0.47.0                                   0.55.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-27145       v1.21.1                                   1.25.11, 1.26.4                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-27145       v1.22.12                                  1.25.11, 1.26.4                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-27145       v1.24.1                                   1.25.11, 1.26.4                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-27145       v1.25.5                                   1.25.11, 1.26.4                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           go.opentelemetry.io/otel                 CVE-2026-29181       v1.36.0                                   1.41.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-32280       v1.21.1                                   1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-32280       v1.22.12                                  1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-32280       v1.24.1                                   1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-32280       v1.25.5                                   1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-32281       v1.21.1                                   1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-32281       v1.22.12                                  1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-32281       v1.24.1                                   1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-32281       v1.25.5                                   1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-32283       v1.21.1                                   1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-32283       v1.22.12                                  1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-32283       v1.24.1                                   1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-32283       v1.25.5                                   1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           github.com/buger/jsonparser              CVE-2026-32285       v1.1.1                                    1.1.2                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           google.golang.org/grpc                   CVE-2026-33186       v1.59.0                                   1.79.3                             CRITICAL
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           google.golang.org/grpc                   CVE-2026-33186       v1.60.1                                   1.79.3                             CRITICAL
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           google.golang.org/grpc                   CVE-2026-33186       v1.65.0                                   1.79.3                             CRITICAL
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-33811       v1.21.1                                   1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-33811       v1.22.12                                  1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-33811       v1.24.1                                   1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-33811       v1.25.5                                   1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/net                         CVE-2026-33814       v0.17.0                                   0.53.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/net                         CVE-2026-33814       v0.19.0                                   0.53.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/net                         CVE-2026-33814       v0.37.0                                   0.53.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/net                         CVE-2026-33814       v0.47.0                                   0.53.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-33814       v1.21.1                                   1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-33814       v1.22.12                                  1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-33814       v1.24.1                                   1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-33814       v1.25.5                                   1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           github.com/docker/docker                 CVE-2026-34040       v27.1.1+incompatible                      29.3.1                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           poetry                                   CVE-2026-34591       2.2.1                                     2.3.3                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           github.com/moby/spdystream               CVE-2026-35469       v0.5.0                                    0.5.1                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-39820       v1.21.1                                   1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-39820       v1.22.12                                  1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-39820       v1.24.1                                   1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-39820       v1.25.5                                   1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/net                         CVE-2026-39821       v0.17.0                                   0.55.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/net                         CVE-2026-39821       v0.19.0                                   0.55.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/net                         CVE-2026-39821       v0.37.0                                   0.55.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/net                         CVE-2026-39821       v0.47.0                                   0.55.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-39822       v1.21.1                                   1.25.12, 1.26.5, 1.27.0-rc.2       HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-39822       v1.22.12                                  1.25.12, 1.26.5, 1.27.0-rc.2       HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-39822       v1.24.1                                   1.25.12, 1.26.5, 1.27.0-rc.2       HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-39822       v1.25.5                                   1.25.12, 1.26.5, 1.27.0-rc.2       HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2026-39828       v0.14.0                                   0.52.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2026-39828       v0.17.0                                   0.52.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2026-39829       v0.14.0                                   0.52.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2026-39829       v0.17.0                                   0.52.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2026-39830       v0.14.0                                   0.52.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2026-39830       v0.17.0                                   0.52.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2026-39831       v0.14.0                                   0.52.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2026-39831       v0.17.0                                   0.52.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2026-39832       v0.14.0                                   0.52.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2026-39832       v0.17.0                                   0.52.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2026-39835       v0.14.0                                   0.52.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2026-39835       v0.17.0                                   0.52.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-39836       v1.21.1                                   1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-39836       v1.22.12                                  1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-39836       v1.24.1                                   1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-39836       v1.25.5                                   1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           go.opentelemetry.io/otel/sdk             CVE-2026-39883       v1.16.0                                   1.43.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           go.opentelemetry.io/otel/sdk             CVE-2026-39883       v1.20.0                                   1.43.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           github.com/gomarkdown/markdown           CVE-2026-40890       v0.0.0-20230922112808-5421fefb8386        0.0.0-20260411013819-759bbc3e3207  HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           github.com/gomarkdown/markdown           CVE-2026-40890       v0.0.0-20231222211730-1d6d20845b47        0.0.0-20260411013819-759bbc3e3207  HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           dulwich                                  CVE-2026-42305       0.24.10                                   1.2.5                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-42499       v1.21.1                                   1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-42499       v1.22.12                                  1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-42499       v1.24.1                                   1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-42499       v1.25.5                                   1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-42504       v1.21.1                                   1.25.11, 1.26.4                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-42504       v1.22.12                                  1.25.11, 1.26.4                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-42504       v1.24.1                                   1.25.11, 1.26.4                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           stdlib                                   CVE-2026-42504       v1.25.5                                   1.25.11, 1.26.4                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2026-42508       v0.14.0                                   0.52.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2026-42508       v0.17.0                                   0.52.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           dulwich                                  CVE-2026-42563       0.24.10                                   1.2.5                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           urllib3                                  CVE-2026-44431       2.3.0                                     2.7.0                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2026-46595       v0.14.0                                   0.52.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2026-46595       v0.17.0                                   0.52.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2026-46597       v0.14.0                                   0.52.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/crypto                      CVE-2026-46597       v0.17.0                                   0.52.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           starlette                                CVE-2026-48818       0.46.2                                    1.1.0                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           dulwich                                  CVE-2026-52726       0.24.10                                   1.2.5                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           mcp                                      CVE-2026-52869       1.27.1                                    1.27.2                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           mcp                                      CVE-2026-52870       1.27.1                                    1.27.2                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           python-multipart                         CVE-2026-53539       0.0.29                                    0.0.30                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           starlette                                CVE-2026-54283       0.46.2                                    1.3.1                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/text                        CVE-2026-56852       v0.13.0                                   0.39.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/text                        CVE-2026-56852       v0.14.0                                   0.39.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/text                        CVE-2026-56852       v0.23.0                                   0.39.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           golang.org/x/text                        CVE-2026-56852       v0.31.0                                   0.39.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           tar                                      CVE-2026-59873       7.5.16                                    7.5.19                             CRITICAL
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           tar                                      CVE-2026-59874       7.5.16                                    7.5.18                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           pyasn1                                   CVE-2026-59885       0.6.3                                     0.6.4                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           pyasn1                                   CVE-2026-59886       0.6.3                                     0.6.4                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           mcp                                      CVE-2026-59950       1.27.1                                    1.28.1                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           GitPython                                GHSA-2f96-g7mh-g2hx  3.1.50                                    3.1.51                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           GitPython                                GHSA-3rp5-jjmw-4wv2  3.1.50                                    3.1.53                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           cryptography                             GHSA-537c-gmf6-5ccf  48.0.0                                    48.0.1                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           GitPython                                GHSA-6p8h-3wgx-97gf  3.1.50                                    3.1.54                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           msgpack                                  GHSA-6v7p-g79w-8964  1.1.2                                     1.2.1                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           GitPython                                GHSA-94p4-4cq8-9g67  3.1.50                                    3.1.55                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           GitPython                                GHSA-956x-8gvw-wg5v  3.1.50                                    3.1.51                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           GitPython                                GHSA-fjr4-x663-mwxc  3.1.50                                    3.1.54                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           google.golang.org/grpc                   GHSA-hrxh-6v49-42gf  v1.59.0                                   1.82.1                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           google.golang.org/grpc                   GHSA-hrxh-6v49-42gf  v1.60.1                                   1.82.1                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           google.golang.org/grpc                   GHSA-hrxh-6v49-42gf  v1.65.0                                   1.82.1                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           GitPython                                GHSA-r9mr-m37c-5fr3  3.1.50                                    3.1.54                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           GitPython                                GHSA-rwj8-pgh3-r573  3.1.50                                    3.1.52                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:0.11.8                           GitPython                                GHSA-v396-v7q4-x2qj  3.1.50                                    3.1.51                             HIGH
ghcr.io/runwhen-contrib/rw-public-codecollection:main-a4247b5-c08539c  System.Security.Cryptography.Xml         CVE-2026-47302       10.0.6                                    10.0.10, 9.0.18, 8.0.4             HIGH
ghcr.io/runwhen-contrib/rw-public-codecollection:main-a4247b5-c08539c  System.Security.Cryptography.Xml         CVE-2026-47304       10.0.6                                    10.0.10, 9.0.18, 8.0.4             HIGH
ghcr.io/runwhen-contrib/rw-public-codecollection:main-a4247b5-c08539c  System.Security.Cryptography.Xml         CVE-2026-50525       10.0.6                                    10.0.10, 9.0.18, 8.0.4             HIGH
ghcr.io/runwhen-contrib/rw-public-codecollection:main-a4247b5-c08539c  System.Security.Cryptography.Xml         CVE-2026-50527       10.0.6                                    10.0.10, 9.0.18, 8.0.4             HIGH
ghcr.io/runwhen-contrib/rw-public-codecollection:main-a4247b5-c08539c  System.Security.Cryptography.Xml         CVE-2026-50648       10.0.6                                    10.0.10, 9.0.18, 8.0.4             HIGH
otel/opentelemetry-collector:0.153.0                                   stdlib                                   CVE-2026-27145       v1.26.3                                   1.25.11, 1.26.4                    HIGH
otel/opentelemetry-collector:0.153.0                                   stdlib                                   CVE-2026-39822       v1.26.3                                   1.25.12, 1.26.5, 1.27.0-rc.2       HIGH
otel/opentelemetry-collector:0.153.0                                   stdlib                                   CVE-2026-42504       v1.26.3                                   1.25.11, 1.26.4                    HIGH
```
<!-- END_TRIVY_SUMMARY -->

**Below, you can find the list of images that were scanned and may be utilized while executing Tasks securely in your infrastructure.**  
<!-- START_SCANNED_IMAGES -->
```

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
