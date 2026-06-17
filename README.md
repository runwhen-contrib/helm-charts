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
Registry                                                              Package                         Vulnerability ID     Installed Version                   Fixed Version                      Severity
--------                                                              -------                         ----------------     -----------------                   -------------                      --------
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2023-39325       v1.21.1                             1.20.10, 1.21.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2023-45283       v1.21.1                             1.20.11, 1.21.4, 1.20.12, 1.21.5   HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2023-45288       v1.21.1                             1.21.9, 1.22.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2024-24790       v1.21.1                             1.21.11, 1.22.4                    CRITICAL
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2024-34156       v1.21.1                             1.22.7, 1.23.1                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          golang.org/x/crypto             CVE-2024-45337       v0.14.0                             0.31.0                             CRITICAL
ghcr.io/runwhen-contrib/runwhen-local:latest                          golang.org/x/crypto             CVE-2024-45337       v0.17.0                             0.31.0                             CRITICAL
ghcr.io/runwhen-contrib/runwhen-local:latest                          golang.org/x/oauth2             CVE-2025-22868       v0.13.0                             0.27.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          golang.org/x/crypto             CVE-2025-22869       v0.14.0                             0.35.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          golang.org/x/crypto             CVE-2025-22869       v0.17.0                             0.35.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2025-22874       v1.24.1                             1.24.4                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          github.com/golang-jwt/jwt/v4    CVE-2025-30204       v4.5.0                              4.5.2                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2025-61726       v1.21.1                             1.24.12, 1.25.6                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2025-61726       v1.22.12                            1.24.12, 1.25.6                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2025-61726       v1.24.1                             1.24.12, 1.25.6                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2025-61726       v1.25.5                             1.24.12, 1.25.6                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2025-61729       v1.21.1                             1.24.11, 1.25.5                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2025-61729       v1.22.12                            1.24.11, 1.25.5                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2025-61729       v1.24.1                             1.24.11, 1.25.5                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          urllib3                         CVE-2025-66418       2.3.0                               2.6.0                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          urllib3                         CVE-2025-66471       2.3.0                               2.6.0                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2025-68121       v1.21.1                             1.24.13, 1.25.7, 1.26.0-rc.3       CRITICAL
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2025-68121       v1.22.12                            1.24.13, 1.25.7, 1.26.0-rc.3       CRITICAL
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2025-68121       v1.24.1                             1.24.13, 1.25.7, 1.26.0-rc.3       CRITICAL
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2025-68121       v1.25.5                             1.24.13, 1.25.7, 1.26.0-rc.3       CRITICAL
ghcr.io/runwhen-contrib/runwhen-local:latest                          urllib3                         CVE-2026-21441       2.3.0                               2.6.3                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-25679       v1.21.1                             1.25.8, 1.26.1                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-25679       v1.22.12                            1.25.8, 1.26.1                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-25679       v1.24.1                             1.25.8, 1.26.1                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-25679       v1.25.5                             1.25.8, 1.26.1                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          go.opentelemetry.io/otel        CVE-2026-29181       v1.36.0                             1.41.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-32280       v1.21.1                             1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-32280       v1.22.12                            1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-32280       v1.24.1                             1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-32280       v1.25.5                             1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-32281       v1.21.1                             1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-32281       v1.22.12                            1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-32281       v1.24.1                             1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-32281       v1.25.5                             1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-32283       v1.21.1                             1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-32283       v1.22.12                            1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-32283       v1.24.1                             1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-32283       v1.25.5                             1.25.9, 1.26.2                     HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          github.com/buger/jsonparser     CVE-2026-32285       v1.1.1                              1.1.2                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          google.golang.org/grpc          CVE-2026-33186       v1.59.0                             1.79.3                             CRITICAL
ghcr.io/runwhen-contrib/runwhen-local:latest                          google.golang.org/grpc          CVE-2026-33186       v1.60.1                             1.79.3                             CRITICAL
ghcr.io/runwhen-contrib/runwhen-local:latest                          google.golang.org/grpc          CVE-2026-33186       v1.65.0                             1.79.3                             CRITICAL
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-33811       v1.21.1                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-33811       v1.22.12                            1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-33811       v1.24.1                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-33811       v1.25.5                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-33811       v1.25.9                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-33814       v1.21.1                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-33814       v1.22.12                            1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-33814       v1.24.1                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-33814       v1.25.5                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-33814       v1.25.9                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          github.com/docker/docker        CVE-2026-34040       v27.1.1+incompatible                29.3.1                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          poetry                          CVE-2026-34591       2.2.1                               2.3.3                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          github.com/moby/spdystream      CVE-2026-35469       v0.5.0                              0.5.1                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-39820       v1.21.1                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-39820       v1.22.12                            1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-39820       v1.24.1                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-39820       v1.25.5                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-39820       v1.25.9                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-39823       v1.21.1                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-39823       v1.22.12                            1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-39823       v1.24.1                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-39823       v1.25.5                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-39823       v1.25.9                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-39825       v1.21.1                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-39825       v1.22.12                            1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-39825       v1.24.1                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-39825       v1.25.5                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-39825       v1.25.9                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-39836       v1.21.1                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-39836       v1.22.12                            1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-39836       v1.24.1                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-39836       v1.25.5                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-39836       v1.25.9                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          go.opentelemetry.io/otel/sdk    CVE-2026-39883       v1.16.0                             1.43.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          go.opentelemetry.io/otel/sdk    CVE-2026-39883       v1.20.0                             1.43.0                             HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          github.com/gomarkdown/markdown  CVE-2026-40890       v0.0.0-20230922112808-5421fefb8386  0.0.0-20260411013819-759bbc3e3207  HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          github.com/gomarkdown/markdown  CVE-2026-40890       v0.0.0-20231222211730-1d6d20845b47  0.0.0-20260411013819-759bbc3e3207  HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          dulwich                         CVE-2026-42305       0.24.10                             1.2.5                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-42499       v1.21.1                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-42499       v1.22.12                            1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-42499       v1.24.1                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-42499       v1.25.5                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-42499       v1.25.9                             1.25.10, 1.26.3                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-42504       v1.21.1                             1.25.11, 1.26.4                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-42504       v1.22.12                            1.25.11, 1.26.4                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-42504       v1.24.1                             1.25.11, 1.26.4                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-42504       v1.25.5                             1.25.11, 1.26.4                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          stdlib                          CVE-2026-42504       v1.25.9                             1.25.11, 1.26.4                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          dulwich                         CVE-2026-42563       0.24.10                             1.2.5                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          urllib3                         CVE-2026-44431       2.3.0                               2.7.0                              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          libssl3t64                      CVE-2026-45447       3.5.6-1~deb13u1                     3.5.6-1~deb13u2                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          openssl                         CVE-2026-45447       3.5.6-1~deb13u1                     3.5.6-1~deb13u2                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          openssl-provider-legacy         CVE-2026-45447       3.5.6-1~deb13u1                     3.5.6-1~deb13u2                    HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest                          cryptography                    GHSA-537c-gmf6-5ccf  48.0.0                              48.0.1                             HIGH
otel/opentelemetry-collector:0.153.0                                  stdlib                          CVE-2026-42504       v1.26.3                             1.25.11, 1.26.4                    HIGH
us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner:latest  golang.org/x/oauth2             CVE-2025-22868       v0.24.0                             0.27.0                             HIGH
us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner:latest  stdlib                          CVE-2026-25679       v1.24.13                            1.25.8, 1.26.1                     HIGH
us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner:latest  stdlib                          CVE-2026-32280       v1.24.13                            1.25.9, 1.26.2                     HIGH
us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner:latest  stdlib                          CVE-2026-32281       v1.24.13                            1.25.9, 1.26.2                     HIGH
us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner:latest  stdlib                          CVE-2026-32283       v1.24.13                            1.25.9, 1.26.2                     HIGH
us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner:latest  stdlib                          CVE-2026-33811       v1.24.13                            1.25.10, 1.26.3                    HIGH
us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner:latest  stdlib                          CVE-2026-33814       v1.24.13                            1.25.10, 1.26.3                    HIGH
us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner:latest  github.com/go-jose/go-jose/v4   CVE-2026-34986       v4.1.1                              4.1.4                              HIGH
us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner:latest  stdlib                          CVE-2026-39820       v1.24.13                            1.25.10, 1.26.3                    HIGH
us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner:latest  stdlib                          CVE-2026-39823       v1.24.13                            1.25.10, 1.26.3                    HIGH
us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner:latest  stdlib                          CVE-2026-39825       v1.24.13                            1.25.10, 1.26.3                    HIGH
us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner:latest  stdlib                          CVE-2026-39836       v1.24.13                            1.25.10, 1.26.3                    HIGH
us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner:latest  stdlib                          CVE-2026-42499       v1.24.13                            1.25.10, 1.26.3                    HIGH
us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner:latest  stdlib                          CVE-2026-42504       v1.24.13                            1.25.11, 1.26.4                    HIGH
```
<!-- END_TRIVY_SUMMARY -->

**Below, you can find the list of images that were scanned and may be utilized while executing Tasks securely in your infrastructure.**  
<!-- START_SCANNED_IMAGES -->
```

ghcr.io/runwhen-contrib/runwhen-local:latest
otel/opentelemetry-collector:0.153.0
us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner:latest
us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/runwhen-contrib-aws-c7n-codecollection-main:latest
us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/runwhen-contrib-azure-c7n-codecollection-main:latest
us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/runwhen-contrib-rw-cli-codecollection-main:latest
us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/runwhen-contrib-rw-generic-codecollection-main:latest
us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/runwhen-contrib-rw-public-codecollection-main:latest
us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/runwhen-contrib-rw-workspace-utils-main:latest
us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/runwhen-contrib-ternary-codecollection-main:latest
```
<!-- END_SCANNED_IMAGES -->
