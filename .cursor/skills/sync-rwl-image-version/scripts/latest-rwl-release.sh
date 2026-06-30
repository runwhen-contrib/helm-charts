#!/usr/bin/env bash
#
# Print the latest runwhen-local GitHub release tag without the leading "v".
# Used when pinning charts/runwhen-local Chart.yaml appVersion.
#
# Usage (from helm-charts repo root):
#   .cursor/skills/sync-rwl-image-version/scripts/latest-rwl-release.sh
#
# Requires: gh (GitHub CLI), authenticated for runwhen-contrib/runwhen-local.

set -euo pipefail

REPO="${RWL_REPO:-runwhen-contrib/runwhen-local}"

tag="$(gh release view --repo "$REPO" --json tagName -q '.tagName')"
if [[ -z "$tag" ]]; then
  echo "ERROR: no latest release found for $REPO" >&2
  exit 1
fi

printf '%s\n' "${tag#v}"
