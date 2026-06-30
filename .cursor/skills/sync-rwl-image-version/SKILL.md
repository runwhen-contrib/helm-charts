---
name: sync-rwl-image-version
description: >-
  Resolve and pin the latest runwhen-contrib/runwhen-local release in the
  runwhen-local Helm chart. Use when bumping charts/runwhen-local appVersion,
  changing workspaceBuilder.image defaults, cutting a chart release that ships
  the workspace-builder image, or whenever the chart must not default to the
  floating "latest" tag.
---

# Sync runwhen-local image version in the Helm chart

The workspace-builder image must **never** default to the floating `latest` tag.
Pin it to a concrete [runwhen-local release](https://github.com/runwhen-contrib/runwhen-local/releases)
via `Chart.yaml` `appVersion`, with `workspaceBuilder.image.tag` left empty so
the template falls back to that value.

## When to apply

- Cutting or updating `charts/runwhen-local` for a new runwhen-local release
- Reviewing a PR that touches `workspaceBuilder.image`, `Chart.yaml` `appVersion`,
  or workspace-builder deployment image wiring
- Any task where an agent might set `tag: latest` — **do not**; fetch the release instead

## Step 1 — Resolve the latest release

From the **helm-charts** repo root, run:

```bash
.cursor/skills/sync-rwl-image-version/scripts/latest-rwl-release.sh
```

Or manually:

```bash
gh release view --repo runwhen-contrib/runwhen-local --json tagName -q '.tagName'
```

The script prints the tag **without** the leading `v` (e.g. `0.11.0`). Container
tags on GHCR match that form.

Optional override for forks or pre-release testing:

```bash
RWL_REPO=runwhen-contrib/runwhen-local .cursor/skills/sync-rwl-image-version/scripts/latest-rwl-release.sh
```

## Step 2 — Pin the chart

1. Set `charts/runwhen-local/Chart.yaml` → `appVersion: "<version>"` (quoted semver,
   no `v` prefix).
2. Keep `workspaceBuilder.image.tag` **empty** in `values.yaml`:

   ```yaml
   workspaceBuilder:
     image:
       tag: ""
   ```

   The deployment template resolves the image as:

   ```yaml
   {{ include "runwhen-local.image" (list . $wb.image "ghcr.io" "runwhen-contrib/runwhen-local" .Chart.AppVersion) }}
   ```

3. Bump `Chart.yaml` `version` (chart semver) when publishing a chart release.
4. Do **not** set `tag: latest` in defaults or examples.

## Step 3 — Verify render

```bash
cd charts/runwhen-local && helm dependency update
helm template test ../runwhen-local \
  --show-only templates/workspace-builder-deployment.yaml | rg 'image:'
```

Expect:

```text
image: "ghcr.io/runwhen-contrib/runwhen-local:0.11.0"
```

(version must match `appVersion`, not `latest`).

## Cross-checks

| File | What to verify |
|------|----------------|
| `Chart.yaml` | `appVersion` matches latest RWL release |
| `values.yaml` | `workspaceBuilder.image.tag` is `""` |
| `README.md` | Does not tell operators to use `latest` |
| `workspace-builder-deployment.yaml` | Fallback tag arg is `.Chart.AppVersion` |

## Runner image (out of scope)

`runner.image` uses a separate registry/tag (`us-docker.pkg.dev/.../runner`) and
is **not** tied to runwhen-local releases. Do not conflate the two when bumping
`appVersion`.
