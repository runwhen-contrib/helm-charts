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
Registry                                      Package                       Vulnerability ID  Installed Version      Fixed Version          Severity
--------                                      -------                       ----------------  -----------------      -------------          --------
ghcr.io/runwhen-contrib/runwhen-local:latest  vim                           CVE-2023-2610     2:9.0.1378-2           2:9.0.1378-2+deb12u1   HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  vim-common                    CVE-2023-2610     2:9.0.1378-2           2:9.0.1378-2+deb12u1   HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  vim-runtime                   CVE-2023-2610     2:9.0.1378-2           2:9.0.1378-2+deb12u1   HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  vim                           CVE-2023-4738     2:9.0.1378-2           2:9.0.1378-2+deb12u1   HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  vim-common                    CVE-2023-4738     2:9.0.1378-2           2:9.0.1378-2+deb12u1   HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  vim-runtime                   CVE-2023-4738     2:9.0.1378-2           2:9.0.1378-2+deb12u1   HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  vim                           CVE-2023-4752     2:9.0.1378-2           2:9.0.1378-2+deb12u1   HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  vim-common                    CVE-2023-4752     2:9.0.1378-2           2:9.0.1378-2+deb12u1   HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  vim-runtime                   CVE-2023-4752     2:9.0.1378-2           2:9.0.1378-2+deb12u1   HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  vim                           CVE-2023-4781     2:9.0.1378-2           2:9.0.1378-2+deb12u1   HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  vim-common                    CVE-2023-4781     2:9.0.1378-2           2:9.0.1378-2+deb12u1   HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  vim-runtime                   CVE-2023-4781     2:9.0.1378-2           2:9.0.1378-2+deb12u1   HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  vim                           CVE-2023-5344     2:9.0.1378-2           2:9.0.1378-2+deb12u1   HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  vim-common                    CVE-2023-5344     2:9.0.1378-2           2:9.0.1378-2+deb12u1   HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  vim-runtime                   CVE-2023-5344     2:9.0.1378-2           2:9.0.1378-2+deb12u1   HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  vim                           CVE-2024-22667    2:9.0.1378-2           2:9.0.1378-2+deb12u1   HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  vim-common                    CVE-2024-22667    2:9.0.1378-2           2:9.0.1378-2+deb12u1   HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  vim-runtime                   CVE-2024-22667    2:9.0.1378-2           2:9.0.1378-2+deb12u1   HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  wget                          CVE-2024-38428    1.21.3-1+b2            1.21.3-1+deb12u1       CRITICAL
ghcr.io/runwhen-contrib/runwhen-local:latest  linux-libc-dev                CVE-2024-49989    6.1.128-1              6.1.129-1              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  linux-libc-dev                CVE-2024-50061    6.1.128-1              6.1.129-1              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  linux-libc-dev                CVE-2024-57980    6.1.128-1              6.1.129-1              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  linux-libc-dev                CVE-2024-58007    6.1.128-1              6.1.129-1              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  linux-libc-dev                CVE-2024-58069    6.1.128-1              6.1.129-1              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  linux-libc-dev                CVE-2025-21703    6.1.128-1              6.1.129-1              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  linux-libc-dev                CVE-2025-21718    6.1.128-1              6.1.129-1              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  linux-libc-dev                CVE-2025-21726    6.1.128-1              6.1.129-1              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  linux-libc-dev                CVE-2025-21735    6.1.128-1              6.1.129-1              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  linux-libc-dev                CVE-2025-21753    6.1.128-1              6.1.129-1              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  linux-libc-dev                CVE-2025-21780    6.1.128-1              6.1.129-1              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  linux-libc-dev                CVE-2025-21782    6.1.128-1              6.1.129-1              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  linux-libc-dev                CVE-2025-21785    6.1.128-1              6.1.129-1              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  linux-libc-dev                CVE-2025-21791    6.1.128-1              6.1.129-1              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  linux-libc-dev                CVE-2025-21794    6.1.128-1              6.1.129-1              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  linux-libc-dev                CVE-2025-21812    6.1.128-1              6.1.129-1              HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  libfreetype6                  CVE-2025-27363    2.12.1+dfsg-5+deb12u3  2.12.1+dfsg-5+deb12u4  HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  github.com/golang-jwt/jwt/v4  CVE-2025-30204    v4.5.1                 4.5.2                  HIGH
ghcr.io/runwhen-contrib/runwhen-local:latest  github.com/golang-jwt/jwt/v5  CVE-2025-30204    v5.2.1                 5.2.2                  HIGH
otel/opentelemetry-collector:0.120.0          github.com/expr-lang/expr     CVE-2025-29786    v1.16.9                1.17.0                 HIGH
```
<!-- END_TRIVY_SUMMARY -->