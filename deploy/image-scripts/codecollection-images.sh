#!/usr/bin/env bash
###############################################################################
# codecollection-images.sh
#
# Append the canonical set of RunWhen CodeCollection container images to
# `registries.txt`. The authoritative source is the RunWhen platform
# catalog API:
#
#   https://registry.runwhen.com/api/v1/catalog/codecollections
#
# Each catalog entry exposes `image_registry` (the ghcr.io path the
# codecollection actually publishes to) and `stable_image_tag` (the tag
# pinned in production). Earlier revisions of this script fabricated a
# `us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/...`
# mirror path which (a) doesn't host every codecollection and (b)
# silently skipped images Trivy couldn't pull, masking real CVEs.
#
# Output: `<image_registry>:<stable_image_tag>` per line, public-only,
# de-duped, sorted, appended to `registries.txt` in the working dir.
#
# Dependencies: curl, jq.
###############################################################################
set -euo pipefail

api_url="https://registry.runwhen.com/api/v1/catalog/codecollections"
catalog_file="$(mktemp -t catalog.XXXXXX.json)"
trap 'rm -f "${catalog_file}"' EXIT

echo "Fetching codecollection catalog from ${api_url}..."
if ! curl -fsSL "${api_url}" -o "${catalog_file}"; then
  echo "ERROR: Failed to fetch codecollection catalog from ${api_url}" >&2
  exit 1
fi

count=$(jq 'length' "${catalog_file}")
if [[ -z "${count}" || "${count}" -lt 1 ]]; then
  echo "ERROR: Codecollection catalog is empty or invalid:" >&2
  cat "${catalog_file}" >&2
  exit 1
fi
echo "Catalog returned ${count} codecollection(s)."

# Public visibility filter keeps hidden/personal orgs out of CI summaries.
jq -r '
  map(select(.visibility == "public"
             and (.image_registry // "") != ""
             and (.stable_image_tag // "") != ""))
  | .[]
  | "\(.image_registry):\(.stable_image_tag)"
' "${catalog_file}" >> registries.txt

sort -u registries.txt -o registries.txt

echo "Updated list of registries after adding codecollections:"
cat registries.txt
echo "Total registries found: $(wc -l < registries.txt)"
