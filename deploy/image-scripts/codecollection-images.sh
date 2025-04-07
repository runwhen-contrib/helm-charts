#!/bin/bash

registry_prefix="us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images"
branch="main"

curl -L https://raw.githubusercontent.com/runwhen-contrib/codecollection-registry/main/codecollections.yaml -o codecollections.yaml
rm registries.txt || true
# 2) Determine the branch name to use (default to 'main' if empty)
branch="${{ steps.determine-branch.outputs.BRANCH_NAME }}"
if [ -z "$branch" ]; then
branch="main"
fi

# 3) Extract 'org' and 'codecollection' from each 'git_url'
# Example line:  git_url: https://github.com/runwhen-solution-samples/tanzu-advanced
# This yields org=runwhen-solution-samples, codecollection=tanzu-advanced
grep -E 'git_url:' codecollections.yaml \
| sed -E 's|.*github.com/([^/]+)/([^/[:space:]]+)(\.git)?|\1 \2|' \
> codecollections_raw.txt

echo "Extracted org and codecollection from codecollections.yaml:"
cat codecollections_raw.txt

# 4) Construct the image pattern: us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/${org}-${codecollection}-${branch}:latest
while read -r org codecollection; do
# Trim possible trailing .git if it wasn't removed by sed
codecollection="${codecollection%.git}"
echo "us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/${org}-${codecollection}-${branch}:latest"
done < codecollections_raw.txt >> registries.txt

# 5) Sort & ensure uniqueness
sort -u registries.txt -o registries.txt

echo "Updated list of registries after adding codecollections:"
cat registries.txt
echo "Total registries found: $(wc -l < registries.txt)"
