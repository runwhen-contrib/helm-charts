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
Registry                                                                      Package                                  Vulnerability ID     Installed Version                         Fixed Version                     Severity
--------                                                                      -------                                  ----------------     -----------------                         -------------                     --------
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           istio.io/istio                           CVE-2019-14993       v0.0.0-20260409200358-0c774325b938+dirty  1.1.13, 1.2.4                     HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           istio.io/istio                           CVE-2021-39155       v0.0.0-20260409200358-0c774325b938+dirty  1.9.8, 1.10.4, 1.11.1             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           istio.io/istio                           CVE-2021-39156       v0.0.0-20260409200358-0c774325b938+dirty  1.9.8, 1.10.4, 1.11.1             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2021-41771       v1.17.1                                   1.16.10, 1.17.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2021-41772       v1.17.1                                   1.16.10, 1.17.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2021-44716       v1.17.1                                   1.16.12, 1.17.5                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           istio.io/istio                           CVE-2022-23635       v0.0.0-20260409200358-0c774325b938+dirty  1.13.1, 1.12.4, 1.11.7            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-23772       v1.17.1                                   1.16.14, 1.17.7                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-23806       v1.17.1                                   1.16.14, 1.17.7                   CRITICAL
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-24675       v1.17.1                                   1.17.9, 1.18.1                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-24921       v1.17.1                                   1.16.15, 1.17.8                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-27664       v1.17.1                                   1.18.6, 1.19.1                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-28131       v1.17.1                                   1.17.12, 1.18.4                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-28327       v1.17.1                                   1.17.9, 1.18.1                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-2879        v1.17.1                                   1.18.7, 1.19.2                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-2880        v1.17.1                                   1.18.7, 1.19.2                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-29804       v1.17.1                                   1.17.11, 1.18.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-30580       v1.17.1                                   1.17.11, 1.18.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-30630       v1.17.1                                   1.17.12, 1.18.4                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-30631       v1.17.1                                   1.17.12, 1.18.4                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-30632       v1.17.1                                   1.17.12, 1.18.4                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-30633       v1.17.1                                   1.17.12, 1.18.4                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-30634       v1.17.1                                   1.17.11, 1.18.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-30635       v1.17.1                                   1.17.12, 1.18.4                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-32189       v1.17.1                                   1.17.13, 1.18.5                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-41715       v1.17.1                                   1.18.7, 1.19.2                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-41716       v1.17.1                                   1.18.8, 1.19.3                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-41720       v1.17.1                                   1.18.9, 1.19.4                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-41722       v1.17.1                                   1.19.6, 1.20.1                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-41723       v1.17.1                                   1.19.6, 1.20.1                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-41724       v1.17.1                                   1.19.6, 1.20.1                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2022-41725       v1.17.1                                   1.19.6, 1.20.1                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2023-24534       v1.17.1                                   1.19.8, 1.20.3                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2023-24536       v1.17.1                                   1.19.8, 1.20.3                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2023-24537       v1.17.1                                   1.19.8, 1.20.3                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2023-24538       v1.17.1                                   1.19.8, 1.20.3                    CRITICAL
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2023-24539       v1.17.1                                   1.19.9, 1.20.4                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2023-24540       v1.17.1                                   1.19.9, 1.20.4                    CRITICAL
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2023-29400       v1.17.1                                   1.19.9, 1.20.4                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2023-29403       v1.17.1                                   1.19.10, 1.20.5                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2023-39325       v1.17.1                                   1.20.10, 1.21.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2023-45283       v1.17.1                                   1.20.11, 1.21.4, 1.20.12, 1.21.5  HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2023-45287       v1.17.1                                   1.20.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2023-45288       v1.17.1                                   1.21.9, 1.22.2                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2024-24790       v1.17.1                                   1.21.11, 1.22.4                   CRITICAL
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2024-34156       v1.17.1                                   1.22.7, 1.23.1                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/oauth2                      CVE-2025-22868       v0.24.0                                   0.27.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2025-61726       v1.17.1                                   1.24.12, 1.25.6                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2025-61729       v1.17.1                                   1.24.11, 1.25.5                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2025-68121       v1.17.1                                   1.24.13, 1.25.7, 1.26.0-rc.3      CRITICAL
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           go.opentelemetry.io/otel/sdk             CVE-2026-24051       v1.35.0                                   1.40.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-25679       v1.17.1                                   1.25.8, 1.26.1                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-25679       v1.24.13                                  1.25.8, 1.26.1                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/net                         CVE-2026-25681       v0.42.0                                   0.55.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/net                         CVE-2026-25681       v0.47.0                                   0.55.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/net                         CVE-2026-25681       v0.49.0                                   0.55.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/net                         CVE-2026-25681       v0.52.0                                   0.55.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/net                         CVE-2026-25681       v0.53.0                                   0.55.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           cryptography                             CVE-2026-26007       43.0.1                                    46.0.5                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           Microsoft.NETCore.App.Runtime.linux-x64  CVE-2026-26127       9.0.10                                    9.0.14, 10.0.4                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           System.Security.Cryptography.Xml         CVE-2026-26171       9.0.10                                    10.0.6, 9.0.15, 8.0.3             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/net                         CVE-2026-27136       v0.42.0                                   0.55.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/net                         CVE-2026-27136       v0.47.0                                   0.55.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/net                         CVE-2026-27136       v0.49.0                                   0.55.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/net                         CVE-2026-27136       v0.52.0                                   0.55.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/net                         CVE-2026-27136       v0.53.0                                   0.55.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-27145       v1.17.1                                   1.25.11, 1.26.4                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-27145       v1.24.13                                  1.25.11, 1.26.4                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-27145       v1.25.9                                   1.25.11, 1.26.4                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-27145       v1.26.2                                   1.25.11, 1.26.4                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           pyOpenSSL                                CVE-2026-27459       24.2.1                                    26.0.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           go.opentelemetry.io/otel                 CVE-2026-29181       v1.40.0                                   1.41.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-32280       v1.17.1                                   1.25.9, 1.26.2                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-32280       v1.24.13                                  1.25.9, 1.26.2                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-32281       v1.17.1                                   1.25.9, 1.26.2                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-32281       v1.24.13                                  1.25.9, 1.26.2                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-32283       v1.17.1                                   1.25.9, 1.26.2                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-32283       v1.24.13                                  1.25.9, 1.26.2                    HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           System.Security.Cryptography.Xml         CVE-2026-33116       9.0.10                                    10.0.6, 9.0.15, 8.0.3             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-33811       v1.17.1                                   1.25.10, 1.26.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-33811       v1.24.13                                  1.25.10, 1.26.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-33811       v1.25.9                                   1.25.10, 1.26.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-33811       v1.26.2                                   1.25.10, 1.26.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/net                         CVE-2026-33814       v0.42.0                                   0.53.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/net                         CVE-2026-33814       v0.47.0                                   0.53.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/net                         CVE-2026-33814       v0.49.0                                   0.53.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/net                         CVE-2026-33814       v0.52.0                                   0.53.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-33814       v1.17.1                                   1.25.10, 1.26.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-33814       v1.24.13                                  1.25.10, 1.26.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-33814       v1.25.9                                   1.25.10, 1.26.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-33814       v1.26.2                                   1.25.10, 1.26.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           github.com/go-jose/go-jose/v4            CVE-2026-34986       v4.1.1                                    4.1.4                             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           github.com/moby/spdystream               CVE-2026-35469       v0.5.0                                    0.5.1                             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-39820       v1.17.1                                   1.25.10, 1.26.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-39820       v1.24.13                                  1.25.10, 1.26.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-39820       v1.25.9                                   1.25.10, 1.26.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-39820       v1.26.2                                   1.25.10, 1.26.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/net                         CVE-2026-39821       v0.42.0                                   0.55.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/net                         CVE-2026-39821       v0.47.0                                   0.55.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/net                         CVE-2026-39821       v0.49.0                                   0.55.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/net                         CVE-2026-39821       v0.52.0                                   0.55.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/net                         CVE-2026-39821       v0.53.0                                   0.55.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-39822       v1.17.1                                   1.25.12, 1.26.5, 1.27.0-rc.2      HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-39822       v1.24.13                                  1.25.12, 1.26.5, 1.27.0-rc.2      HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-39822       v1.25.9                                   1.25.12, 1.26.5, 1.27.0-rc.2      HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-39822       v1.26.2                                   1.25.12, 1.26.5, 1.27.0-rc.2      HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39828       v0.45.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39828       v0.47.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39828       v0.49.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39828       v0.50.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39829       v0.45.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39829       v0.47.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39829       v0.49.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39829       v0.50.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39830       v0.45.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39830       v0.47.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39830       v0.49.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39830       v0.50.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39831       v0.45.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39831       v0.47.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39831       v0.49.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39831       v0.50.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39832       v0.45.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39832       v0.47.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39832       v0.49.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39832       v0.50.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39835       v0.45.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39835       v0.47.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39835       v0.49.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-39835       v0.50.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-39836       v1.17.1                                   1.25.10, 1.26.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-39836       v1.24.13                                  1.25.10, 1.26.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-39836       v1.25.9                                   1.25.10, 1.26.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-39836       v1.26.2                                   1.25.10, 1.26.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           go.opentelemetry.io/otel/sdk             CVE-2026-39883       v1.35.0                                   1.43.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           go.opentelemetry.io/otel/sdk             CVE-2026-39883       v1.40.0                                   1.43.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           github.com/prometheus/prometheus         CVE-2026-42151       v0.310.0                                  0.311.3                           HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           github.com/prometheus/prometheus         CVE-2026-42154       v0.310.0                                  0.311.3, 0.305.2                  HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-42499       v1.17.1                                   1.25.10, 1.26.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-42499       v1.24.13                                  1.25.10, 1.26.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-42499       v1.25.9                                   1.25.10, 1.26.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-42499       v1.26.2                                   1.25.10, 1.26.3                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-42504       v1.17.1                                   1.25.11, 1.26.4                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-42504       v1.24.13                                  1.25.11, 1.26.4                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-42504       v1.25.9                                   1.25.11, 1.26.4                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           stdlib                                   CVE-2026-42504       v1.26.2                                   1.25.11, 1.26.4                   HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-42508       v0.45.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-42508       v0.47.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-42508       v0.49.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-42508       v0.50.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           urllib3                                  CVE-2026-44431       2.6.3                                     2.7.0                             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           urllib3                                  CVE-2026-44432       2.6.3                                     2.7.0                             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-46595       v0.45.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-46595       v0.47.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-46595       v0.49.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-46595       v0.50.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-46597       v0.45.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-46597       v0.47.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-46597       v0.49.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           golang.org/x/crypto                      CVE-2026-46597       v0.50.0                                   0.52.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           github.com/cli/cli/v2                    CVE-2026-48501       v2.92.0                                   2.93.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           PyJWT                                    CVE-2026-48526       2.12.0                                    2.13.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           PyJWT                                    CVE-2026-48526       2.12.1                                    2.13.0                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           github.com/sigstore/rekor                CVE-2026-48702       v1.5.0                                    1.5.2                             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           oras.land/oras-go/v2                     CVE-2026-50151       v2.6.0                                    2.6.1                             HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           cryptography                             GHSA-537c-gmf6-5ccf  43.0.1                                    48.0.1                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           cryptography                             GHSA-537c-gmf6-5ccf  46.0.5                                    48.0.1                            HIGH
ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81           cryptography                             GHSA-537c-gmf6-5ccf  46.0.7                                    48.0.1                            HIGH
ghcr.io/runwhen-contrib/azure-c7n-codecollection:main-96b0ee5-6e4bc81         PyJWT                                    CVE-2026-32597       2.11.0                                    2.12.0                            HIGH
ghcr.io/runwhen-contrib/azure-c7n-codecollection:main-96b0ee5-6e4bc81         PyJWT                                    CVE-2026-48526       2.11.0                                    2.13.0                            HIGH
ghcr.io/runwhen-contrib/rw-cli-codecollection:main-95fdc2e-ff142a8            istio.io/istio                           CVE-2019-14993       v0.0.0-20260624003133-f888ab4c8a0c+dirty  1.1.13, 1.2.4                     HIGH
ghcr.io/runwhen-contrib/rw-cli-codecollection:main-95fdc2e-ff142a8            istio.io/istio                           CVE-2021-39155       v0.0.0-20260624003133-f888ab4c8a0c+dirty  1.9.8, 1.10.4, 1.11.1             HIGH
ghcr.io/runwhen-contrib/rw-cli-codecollection:main-95fdc2e-ff142a8            istio.io/istio                           CVE-2021-39156       v0.0.0-20260624003133-f888ab4c8a0c+dirty  1.9.8, 1.10.4, 1.11.1             HIGH
ghcr.io/runwhen-contrib/rw-cli-codecollection:main-95fdc2e-ff142a8            istio.io/istio                           CVE-2022-23635       v0.0.0-20260624003133-f888ab4c8a0c+dirty  1.13.1, 1.12.4, 1.11.7            HIGH
ghcr.io/runwhen-contrib/rw-cli-codecollection:main-95fdc2e-ff142a8            stdlib                                   CVE-2026-27145       v1.26.3                                   1.25.11, 1.26.4                   HIGH
ghcr.io/runwhen-contrib/rw-cli-codecollection:main-95fdc2e-ff142a8            stdlib                                   CVE-2026-39822       v1.26.3                                   1.25.12, 1.26.5, 1.27.0-rc.2      HIGH
ghcr.io/runwhen-contrib/rw-cli-codecollection:main-95fdc2e-ff142a8            stdlib                                   CVE-2026-39822       v1.26.4                                   1.25.12, 1.26.5, 1.27.0-rc.2      HIGH
ghcr.io/runwhen-contrib/rw-cli-codecollection:main-95fdc2e-ff142a8            stdlib                                   CVE-2026-42504       v1.26.3                                   1.25.11, 1.26.4                   HIGH
ghcr.io/runwhen-contrib/rw-cli-codecollection:main-95fdc2e-ff142a8            piscina                                  CVE-2026-55388       4.9.0                                     5.2.0, 4.9.3, 6.0.0-rc.2          HIGH
ghcr.io/runwhen-contrib/rw-generic-codecollection:main-cda4be5-6e4bc81        cryptography                             GHSA-537c-gmf6-5ccf  48.0.0                                    48.0.1                            HIGH
ghcr.io/runwhen-contrib/rw-public-codecollection:main-705d3d6-6e4bc81         soupsieve                                CVE-2026-49476       2.8.3                                     2.8.4                             HIGH
ghcr.io/runwhen-contrib/rw-public-codecollection:main-705d3d6-6e4bc81         soupsieve                                CVE-2026-49477       2.8.3                                     2.8.4                             HIGH
us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner:r-2026-07-10.1  github.com/docker/docker                 CVE-2026-34040       v28.5.2+incompatible                      29.3.1                            HIGH
```
<!-- END_TRIVY_SUMMARY -->

**Below, you can find the list of images that were scanned and may be utilized while executing Tasks securely in your infrastructure.**  
<!-- START_SCANNED_IMAGES -->
```

ghcr.io/runwhen-contrib/aws-c7n-codecollection:main-ee371fd-6e4bc81
ghcr.io/runwhen-contrib/azure-c7n-codecollection:main-96b0ee5-6e4bc81
ghcr.io/runwhen-contrib/runwhen-local:0.11.4
ghcr.io/runwhen-contrib/rw-cli-codecollection:main-95fdc2e-ff142a8
ghcr.io/runwhen-contrib/rw-generic-codecollection:main-cda4be5-6e4bc81
ghcr.io/runwhen-contrib/rw-public-codecollection:main-705d3d6-6e4bc81
ghcr.io/runwhen-contrib/rw-workspace-utils:main-fe33f4b-6e4bc81
otel/opentelemetry-collector:0.153.0
us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner:r-2026-07-10.1
```
<!-- END_SCANNED_IMAGES -->
