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
Registry                                                                                                   Package                       Vulnerability ID  Installed Version  Fixed Version  Severity
--------                                                                                                   -------                       ----------------  -----------------  -------------  --------
us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/infracloudio-ifc-rw-codecollection-main:latest  github.com/golang-jwt/jwt/v4  CVE-2025-30204    v4.5.1             4.5.2          HIGH
us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/infracloudio-ifc-rw-codecollection-main:latest  github.com/golang-jwt/jwt/v5  CVE-2025-30204    v5.2.1             5.2.2          HIGH
us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/infracloudio-ifc-rw-codecollection-main:latest  setuptools                    CVE-2025-47273    75.8.0             78.1.1         HIGH
```
<!-- END_TRIVY_SUMMARY -->

**Below, you can find the list of images that were scanned and may be utilized while executing Tasks securely in your infrastructure.**  
<!-- START_SCANNED_IMAGES -->
```

ghcr.io/runwhen-contrib/runwhen-local:latest
otel/opentelemetry-collector:0.123.0
us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner:latest
us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/infracloudio-ifc-rw-codecollection-main:latest
us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/runwhen-contrib-aws-c7n-codecollection-main:latest
us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/runwhen-contrib-azure-c7n-codecollection-main:latest
us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/runwhen-contrib-rw-cli-codecollection-main:latest
us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/runwhen-contrib-rw-generic-codecollection-main:latest
us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/runwhen-contrib-rw-public-codecollection-main:latest
us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/runwhen-contrib-rw-workspace-utils-main:latest
us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/runwhen-contrib-ternary-codecollection-main:latest
```
<!-- END_SCANNED_IMAGES -->
