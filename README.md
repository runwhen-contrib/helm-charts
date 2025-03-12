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
Registry                                                              Package           Vulnerability ID  Installed Version  Fixed Version  Severity
--------                                                              -------           ----------------  -----------------  -------------  --------
ghcr.io/runwhen-contrib/runwhen-local:latest                          golang.org/x/net  CVE-2024-45338    v0.30.0            0.33.0         HIGH
us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner:latest  golang.org/x/net  CVE-2024-45338    v0.21.0            0.33.0         HIGH
```
<!-- END_TRIVY_SUMMARY -->