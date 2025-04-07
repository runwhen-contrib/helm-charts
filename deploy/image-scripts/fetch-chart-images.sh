#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Usage:
#   ./extract_images.sh /path/to/chart [values_file.yaml] [extra_images_file.txt]
#
#  - /path/to/chart:     Required. The Helm chart directory to render.
#  - values_file.yaml:   Optional. If you need to supply custom Helm values,
#                        specify your YAML file here.
#  - extra_images_file:  Optional. A file containing additional image references.
#
# Example:
#   ./extract_images.sh ./charts/runwhen-local my-values.yaml my-extra-images.txt
#
# What this script does:
#   1. Renders the Helm chart into YAML.
#   2. Extracts container images from the rendered output.
#   3. (Optionally) merges extra images from another file.
#   4. De-duplicates the combined image list.
#   5. Creates a second script (pull_images.sh) with lines like:
#         docker pull <IMAGE>
#      or:
#         podman pull <IMAGE>
#      depending on what the user chooses.
###############################################################################

# --- 1. Parse input arguments ---
CHART_PATH="${1:-}"
if [[ -z "$CHART_PATH" || ! -d "$CHART_PATH" ]]; then
  echo "Error: Please specify a valid Helm chart directory as the first argument."
  exit 1
fi

VALUES_FILE="${2:-}"
EXTRA_IMAGES_FILE="${3:-}"

RENDERED_YAML="rendered_chart.yaml"
IMAGES_LIST="images.txt"
PULL_SCRIPT="pull_images.sh"

# --- 2. Build dependencies if the chart uses them (safe to ignore if none) ---
echo "Building Helm dependencies for '$CHART_PATH' (if any)..."
helm dependency build "$CHART_PATH" || true

# --- 3. Render Helm chart to YAML ---
echo "Rendering Helm chart..."
if [[ -n "$VALUES_FILE" && -f "$VALUES_FILE" ]]; then
  helm template "$CHART_PATH" -f "$VALUES_FILE" > "$RENDERED_YAML"
else
  helm template "$CHART_PATH" > "$RENDERED_YAML"
fi

if [[ ! -s "$RENDERED_YAML" ]]; then
  echo "Error: Helm rendering failed or produced empty output."
  exit 1
fi

echo "Helm chart rendered to: $RENDERED_YAML"

# --- 4. Extract images from the rendered YAML using 'yq' ---
echo "Extracting images from rendered YAML..."
yq -r '..|.image? | select(.)' "$RENDERED_YAML" > "$IMAGES_LIST" 2>/dev/null || true

# Alternatively, if you don't have yq, you can do:
#   grep -E 'image:\s*' "$RENDERED_YAML" \
#     | sed -E 's/.*image:\s*"?([^"]+)"?/\1/' \
#     >> "$IMAGES_LIST"

# --- 5. (Optional) Add extra images from user-specified file ---
if [[ -n "$EXTRA_IMAGES_FILE" && -f "$EXTRA_IMAGES_FILE" ]]; then
  echo "Merging extra images from: $EXTRA_IMAGES_FILE"
  cat "$EXTRA_IMAGES_FILE" >> "$IMAGES_LIST"
fi

# --- 6. Clean up and deduplicate the list of images ---
sort -u "$IMAGES_LIST" -o "$IMAGES_LIST"
echo "Final list of images:"
cat "$IMAGES_LIST"
echo "Total images: $(wc -l < "$IMAGES_LIST")"

# --- 7. Run codecollection_image.sh ---
./codecollection-images.sh
echo "======================="
echo "All Helm Chart and CodeCollection images that may execute with the Helm Chart Install:"
cat "$IMAGES_LIST"
cat "registries.txt"
