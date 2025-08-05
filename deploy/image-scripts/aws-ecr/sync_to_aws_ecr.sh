#!/bin/bash

# AWS ECR Registry Sync Script
# Syncs container images from various registries to AWS ECR
# Uses docker buildx imagetools create for daemonless image copying
# Extended to include Helm chart image extraction and dynamic CodeCollection discovery

set -euo pipefail

# Set Private Registry (AWS ECR)
private_registry="982534371594.dkr.ecr.us-west-2.amazonaws.com"

# Set AWS Region
aws_region="us-west-2"

# Set Architecture
desired_architecture="amd64"

# Set Destination Prefix for ECR repositories
destination_prefix="test-rwl-runwhen"

# Specify values file
values_file=""
new_values_file="updated_values.yaml"

# Tag exclusion list
tag_exclusion_list=("tester")

# Generate a unique date-based tag
date_based_tag=$(date +%Y%m%d%H%M%S)

# Option to disable date-based tags (use "latest" instead)
disable_date_based_tags=true

# Helm chart configuration
chart_path="runwhen-contrib/runwhen-local"
extra_images_file=""
codecollection_branch="main"
codecollection_registry_prefix="us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images"

# Function to generate RunWhen Local images JSON
generate_runwhen_local_images() {
    cat << EOF
[
  {
    "repository_image": "ghcr.io/runwhen-contrib/runwhen-local",
    "destination": "$destination_prefix/runwhen-local",
    "helm_key": "runwhenLocal"
  },
  {
    "repository_image": "us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner",
    "destination": "$destination_prefix/runner",
    "helm_key": "runner"
  },
  {
    "repository_image": "docker.io/otel/opentelemetry-collector",
    "destination": "$destination_prefix/opentelemetry-collector",
    "helm_key": "opentelemetry/collector"
  }
]
EOF
}

# Function to generate CodeCollection images JSON
generate_codecollection_images() {
    cat << EOF
[
  {
    "repository_image": "us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/runwhen-contrib-rw-cli-codecollection-main",
    "destination": "$destination_prefix/runwhen-contrib-rw-cli-codecollection-main",
    "helm_key": "runner.runEnvironment"
  },
  {
    "repository_image": "us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/runwhen-contrib-rw-public-codecollection-main",
    "destination": "$destination_prefix/runwhen-contrib-rw-public-codecollection-main",
    "helm_key": "runner.runEnvironment"
  },
  {
    "repository_image": "us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/runwhen-contrib-rw-generic-codecollection-main",
    "destination": "$destination_prefix/runwhen-contrib-rw-generic-codecollection-main",
    "helm_key": "runner.runEnvironment"
  },
  {
    "repository_image": "us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/runwhen-contrib-rw-workspace-utils-main",
    "destination": "$destination_prefix/runwhen-contrib-rw-workspace-utils-main",
    "helm_key": "runner.runEnvironment"
  }
]
EOF
}

# RunWhen Local Images - Core functionality images
# Note: These are now extracted from Helm chart instead of being hardcoded
# Static configuration removed to ensure we sync exactly what the chart needs
runwhen_local_images=$(generate_runwhen_local_images)

# CodeCollection Images - Runtime/execution images
# Note: These are now discovered dynamically from codecollections.yaml
# Static configuration removed to avoid duplication
codecollection_images=$(generate_codecollection_images)

# Required tools
required_tools=("jq" "yq" "aws" "docker" "curl" "helm")

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    echo "🔍 Checking prerequisites..."
    
    for tool in "${required_tools[@]}"; do
        if ! command_exists "$tool"; then
            echo "❌ Required tool '$tool' not found"
            exit 1
        fi
    done
    
    # Check if docker buildx is available
    if ! docker buildx version >/dev/null 2>&1; then
        echo "❌ Docker buildx not available. Please install Docker buildx plugin."
        exit 1
    fi
    
    echo "✅ All prerequisites met"
}

# Function to display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

AWS ECR Registry Sync Script

OPTIONS:
    -h, --help              Show this help message
    -v, --verbose           Enable verbose output
    --date-tags             Enable date-based tags (default: use same tag as source)
    -c, --chart PATH        Path to Helm chart directory to extract images from
    -e, --extra-images FILE Path to file containing additional images
    -b, --branch BRANCH     CodeCollection branch to use (default: main)
    -f, --values FILE       Helm values file to use for chart rendering and updates
    -p, --prefix PREFIX     Destination prefix for ECR repositories (default: test-rwl-runwhen)

CONFIGURATION:
    Edit the variables at the top of this script:
    - private_registry: AWS ECR registry URL
    - aws_region: AWS region for ECR
    - new_values_file: Path to output Helm values file

EXAMPLE:
    ./sync_to_aws_ecr.sh
    ./sync_to_aws_ecr.sh --date-tags
    ./sync_to_aws_ecr.sh -c ./charts/runwhen-local -f values.yaml
    ./sync_to_aws_ecr.sh -c ./charts/runwhen-local -f values.yaml -e extra-images.txt

EOF
}

# Function to extract images from Helm chart
extract_helm_chart_images() {
    local chart_path=$1
    local values_file=$2
    local extra_images_file=$3
    
    echo "📦 Extracting images from Helm chart: $chart_path" >&2
    
    # Render Helm chart to YAML
    local rendered_yaml="rendered_chart.yaml"
    
    if [[ -n "$values_file" && -f "$values_file" ]]; then
        helm template "$chart_path" -f "$values_file" > "$rendered_yaml"
    else
        helm template "$chart_path" > "$rendered_yaml"
    fi
    
    if [[ ! -s "$rendered_yaml" ]]; then
        echo "❌ Helm rendering failed or produced empty output." >&2
        return 1
    fi
    
    # Extract images from the rendered YAML using 'yq'
    local images_list="helm_chart_images.txt"
    yq -r '..|.image? | select(.)' "$rendered_yaml" > "$images_list" 2>/dev/null || true
    
    # Add extra images from user-specified file
    if [[ -n "$extra_images_file" && -f "$extra_images_file" ]]; then
        cat "$extra_images_file" >> "$images_list"
    fi
    
    # Clean up and deduplicate the list of images
    sort -u "$images_list" -o "$images_list"
    
    # Convert to JSON format for processing
    local helm_images_json="[]"
    while IFS= read -r image; do
        if [[ -n "$image" && "$image" != "---" ]]; then
            # Extract repository and tag properly
            if [[ "$image" == *":"* ]]; then
                # Image has a tag
                local repo=$(echo "$image" | sed 's/:.*$//')
                local tag=$(echo "$image" | sed 's/^.*://')
            else
                # Image has no tag, use 'latest'
                local repo="$image"
                local tag="latest"
            fi
            
            # Create destination name - use the last part of the repository name
            local repo_name=$(echo "$repo" | sed 's/.*\///')
            local destination="$destination_prefix/$repo_name"
            
            # Add to JSON array
            helm_images_json=$(echo "$helm_images_json" | jq --arg repo "$repo" --arg dest "$destination" --arg tag "$tag" '. += [{"repository_image": $repo, "destination": $dest, "helm_key": "helmChart", "tag": $tag}]')
        fi
    done < "$images_list"
    
    echo "$helm_images_json"
}

# Function to discover CodeCollection images dynamically
discover_codecollection_images() {
    local branch=${1:-main}
    local registry_prefix=${2:-us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images}
    
    echo "🔍 Discovering CodeCollection images for branch: $branch" >&2
    
    # Download codecollections.yaml
    local codecollections_file="codecollections.yaml"
    echo "📥 Downloading codecollections.yaml..." >&2
    if ! curl -L https://raw.githubusercontent.com/runwhen-contrib/codecollection-registry/main/codecollections.yaml -o "$codecollections_file" >&2; then
        echo "❌ Failed to download codecollections.yaml" >&2
        echo "[]"
        return 0
    fi
    
    # Extract 'org' and 'codecollection' from each 'git_url'
    local codecollections_raw="codecollections_raw.txt"
    if ! grep -E 'git_url:' "$codecollections_file" \
        | sed -E 's|.*github.com/([^/]+)/([^/[:space:]]+)(\.git)?|\1 \2|' \
        > "$codecollections_raw"; then
        echo "❌ Failed to extract git URLs from codecollections.yaml" >&2
        rm -f "$codecollections_file"
        echo "[]"
        return 0
    fi
    
    echo "📋 Extracted org and codecollection from codecollections.yaml:" >&2
    cat "$codecollections_raw" >&2
    
    # Construct image names and convert to JSON
    local discovered_images_json="[]"
    while read -r org codecollection; do
        # Skip empty lines
        if [[ -z "$org" || -z "$codecollection" ]]; then
            continue
        fi
        
        # Trim possible trailing .git if it wasn't removed by sed
        codecollection="${codecollection%.git}"
        local image_name="${registry_prefix}/${org}-${codecollection}-${branch}"
        local destination="$destination_prefix/${org}-${codecollection}-${branch}"
        
        # Fetch the most recent tag for this image
        echo "🔍 Fetching most recent tag for: $image_name" >&2
        local most_recent_tag=$(get_available_tags "$image_name" 1 2>/dev/null | head -n1 | tr -d '[:space:]')
        
        if [ -n "$most_recent_tag" ]; then
            echo "✅ Found tag: $most_recent_tag for $image_name" >&2
            local tag_to_use="$most_recent_tag"
        else
            echo "⚠️  No recent tag found for $image_name, using 'latest'" >&2
            local tag_to_use="latest"
        fi
        
        # Add to JSON array - ensure no line breaks in the middle
        discovered_images_json=$(echo "$discovered_images_json" | jq --arg img "$image_name" --arg dest "$destination" --arg tag "$tag_to_use" '. += [{"repository_image": $img, "destination": $dest, "helm_key": "codecollection", "tag": $tag}]' 2>/dev/null || echo "$discovered_images_json")
    done < "$codecollections_raw"
    
    # Clean up temporary files
    rm -f "$codecollections_file" "$codecollections_raw"
    
    echo "📊 Discovered CodeCollection images:" >&2
    if [ "$(echo "$discovered_images_json" | jq length)" -gt 0 ]; then
        echo "$discovered_images_json" | jq -r '.[].repository_image' >&2
        echo "📈 Total discovered CodeCollection images: $(echo "$discovered_images_json" | jq length)" >&2
    else
        echo "📈 No CodeCollection images discovered" >&2
    fi
    
    echo "$discovered_images_json"
}

# Function to create ECR repository if it doesn't exist
create_ecr_repository() {
    local repository_name=$1
    
    echo "🔍 Checking if ECR repository '$repository_name' exists..."
    
    if aws ecr describe-repositories --repository-names "$repository_name" --region "$aws_region" --no-cli-pager >/dev/null 2>&1; then
        echo "✅ Repository '$repository_name' already exists"
    else
        echo "📦 Creating ECR repository '$repository_name'..."
        aws ecr create-repository \
            --repository-name "$repository_name" \
            --region "$aws_region" \
            --image-scanning-configuration scanOnPush=true \
            --encryption-configuration encryptionType=AES256 \
            --no-cli-pager >/dev/null 2>&1
        
        echo "✅ Repository '$repository_name' created successfully"
    fi
}

# Function to copy image using docker buildx (daemonless)
copy_image() {
    repository_image=$1
    src_tag=$2
    destination=$3
    dest_tag=$4

    echo "Copying image: $repository_image:$src_tag to $private_registry/$destination:$dest_tag"
    
    # Create ECR repository if it doesn't exist
    create_ecr_repository "$destination"
    
    # Get ECR authentication token
    echo "Authenticating with ECR..."
    local auth_token=$(aws ecr get-login-password --region "$aws_region" --no-cli-pager)
    if [ -z "$auth_token" ]; then
        echo "❌ Failed to get ECR authentication token"
        return 1
    fi
    
    # Login to ECR using docker
    echo "Logging into ECR..."
    echo "$auth_token" | docker login "$private_registry" --username AWS --password-stdin >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "❌ Failed to login to ECR"
        return 1
    fi
    
    # Use docker buildx with a simple Dockerfile to copy the image
    echo "Copying image using docker buildx..."
    
    # Create a temporary build context
    local temp_context=$(mktemp -d)
    cat > "$temp_context/Dockerfile" << EOF
FROM $repository_image:$src_tag
EOF
    
    # Build and push using docker buildx with proper build context
    if docker buildx build \
        --platform linux/amd64 \
        --file "$temp_context/Dockerfile" \
        --tag "$private_registry/$destination:$dest_tag" \
        --push \
        "$temp_context" 2>/dev/null; then
        echo "✅ Successfully copied image using docker buildx"
        rm -rf "$temp_context"
        return 0
    else
        echo "❌ Failed to copy image using docker buildx"
        echo "   Source: $repository_image:$src_tag"
        echo "   Destination: $private_registry/$destination:$dest_tag"
        echo "   This may be due to:"
        echo "   - Network connectivity issues"
        echo "   - Source image not found or inaccessible"
        echo "   - Insufficient AWS ECR permissions"
        echo "   - Architecture mismatch"
        rm -rf "$temp_context"
        return 1
    fi
}

# Function to check if a tag is in the exclusion list
is_excluded_tag() {
    local tag=$1
    for excluded_tag in "${tag_exclusion_list[@]}"; do
        if [ "$tag" == "$excluded_tag" ]; then
            return 0
        fi
    done
    return 1
}

# Check if the repository image has a tag already specified
has_tag() {
    local repository_image=$1
    local images_json=$2
    echo "$images_json" | jq -e --arg repository_image "$repository_image" '.[] | select(.repository_image == $repository_image) | has("tag")' > /dev/null 2>&1
}

# Function to get available tags for an image
get_available_tags() {
    local repository_image=$1
    local max_tags=${2:-10}
    
    echo "Fetching tags for repository image: $repository_image" >&2

    # Check if the repository image is from Google Artifact Registry
    if [[ $repository_image == *.pkg.dev/* ]]; then
        REPO_URL="https://us-west1-docker.pkg.dev/v2/${repository_image#*pkg.dev/}/tags/list"
        TAGS=$(curl -s "$REPO_URL" | jq -r '.tags[]')
        
        if [ $? -ne 0 ] || [ -z "$TAGS" ]; then
            echo "Failed to fetch tags from Google Artifact Registry: $REPO_URL" >&2
            echo "This may be due to:" >&2
            echo "  - Repository doesn't exist" >&2
            echo "  - Repository is private and requires authentication" >&2
            echo "  - Network connectivity issues" >&2
            return 1
        fi
    elif [[ $repository_image == ghcr.io/* ]]; then
        REPO_URL="https://ghcr.io/v2/${repository_image#*ghcr.io/}/tags/list"
        TAGS=$(curl -s "$REPO_URL" | jq -r '.tags[]')
        
        if [ $? -ne 0 ] || [ -z "$TAGS" ]; then
            echo "Failed to fetch tags from GitHub Container Registry: $REPO_URL" >&2
            echo "This may be due to:" >&2
            echo "  - Repository doesn't exist" >&2
            echo "  - Repository is private and requires authentication" >&2
            echo "  - Network connectivity issues" >&2
            return 1
        fi
    elif [[ $repository_image == docker.io/* ]]; then
        echo "Docker Hub tag fetching not implemented yet" >&2
        return 1
    else
        echo "Unsupported repository type: $repository_image" >&2
        return 1
    fi

    tag_dates=()
    for TAG in $TAGS; do
        echo "Processing tag: $TAG" >&2
        if is_excluded_tag "$TAG" || [[ $TAG == "latest" ]]; then
            echo "Skipping $TAG" >&2
            continue
        fi

        if [[ $repository_image == *.pkg.dev/* ]]; then
            MANIFEST=$(curl -s "https://us-west1-docker.pkg.dev/v2/${repository_image#*pkg.dev/}/manifests/$TAG")

            # Check if the manifest is multi-arch
            media_type=$(echo "$MANIFEST" | jq -r '.mediaType')
            if [ "$media_type" == "application/vnd.docker.distribution.manifest.list.v2+json" ]; then
                # Multi-arch manifest
                MANIFESTS=$(echo "$MANIFEST" | jq -c --arg arch "$desired_architecture" '.manifests[] | select(.platform.architecture == $arch)')
                for MANIFEST_ITEM in $MANIFESTS; do
                    ARCH_MANIFEST_DIGEST=$(echo "$MANIFEST_ITEM" | jq -r '.digest')
                    ARCH_MANIFEST=$(curl -s "https://us-west1-docker.pkg.dev/v2/${repository_image#*pkg.dev/}/manifests/$ARCH_MANIFEST_DIGEST")
                    CONFIG_DIGEST=$(echo "$ARCH_MANIFEST" | jq -r '.config.digest')
                    CONFIG=$(curl -L -s "https://us-west1-docker.pkg.dev/v2/${repository_image#*pkg.dev/}/blobs/$CONFIG_DIGEST")
                    CREATION_DATE=$(echo "$CONFIG" | jq -r '.created')

                    if [ -n "$CREATION_DATE" ]; then
                        tag_dates+=("$CREATION_DATE $TAG")
                        break
                    fi
                done
            else
                # Single-arch manifest
                CONFIG_DIGEST=$(echo "$MANIFEST" | jq -r '.config.digest')
                CONFIG=$(curl -L -s "https://us-west1-docker.pkg.dev/v2/${repository_image#*pkg.dev/}/blobs/$CONFIG_DIGEST")
                CREATION_DATE=$(echo "$CONFIG" | jq -r '.created')
                
                if [ -n "$CREATION_DATE" ]; then
                    tag_dates+=("$CREATION_DATE $TAG")
                fi
            fi
        elif [[ $repository_image == ghcr.io/* ]]; then
            REPO_URL="https://ghcr.io/v2/${repository_image#*ghcr.io/}/manifests/$TAG"
            MANIFEST=$(curl -s "$REPO_URL")
            CONFIG_DIGEST=$(echo "$MANIFEST" | jq -r '.config.digest')
            CONFIG=$(curl -L -s "https://ghcr.io/v2/${repository_image#*ghcr.io/}/blobs/$CONFIG_DIGEST")
            CREATION_DATE=$(echo "$CONFIG" | jq -r '.created')

            if [ -n "$CREATION_DATE" ]; then
                tag_dates+=("$CREATION_DATE $TAG")
            fi
        else
            echo "Unsupported repository type: $repository_image" >&2
            return 1
        fi
    done

    if [ ${#tag_dates[@]} -eq 0 ]; then
        echo "No valid tags found after filtering" >&2
        return 1
    fi

    # Sort tags by creation date and return the most recent ones
    sorted_tags=$(printf "%s\n" "${tag_dates[@]}" | sort -r | awk '{print $2}' | head -n "$max_tags")
    echo "$sorted_tags"
}

# Function to update Helm values file
update_helm_values() {
    local values_file=$1
    local new_values_file=$2
    local image_name=$3
    local new_tag=$4
    
    # Only update if values file is provided
    if [ -z "$values_file" ] || [ ! -f "$values_file" ]; then
        echo "📝 Skipping Helm values update (no values file provided)"
        return 0
    fi
    
    echo "📝 Updating Helm values: $image_name -> $new_tag"
    
    # Create backup of original file
    cp "$values_file" "${values_file}.backup"
    
    # Update the image tag using yq
    yq eval ".images.$image_name.tag = \"$new_tag\"" "$values_file" > "$new_values_file"
    
    if [ $? -eq 0 ]; then
        echo "✅ Updated Helm values file: $new_values_file"
    else
        echo "❌ Failed to update Helm values file"
        return 1
    fi
}

# Function to sync images
sync_images() {
    local images_json=$1
    local image_type=$2
    
    echo "🔄 Starting sync for $image_type images..."
    
    # Parse JSON array
    local images=$(echo "$images_json" | jq -r '.[] | @base64')
    
    for image_base64 in $images; do
        local image_data=$(echo "$image_base64" | base64 -d)
        local repository_image=$(echo "$image_data" | jq -r '.repository_image')
        local destination=$(echo "$image_data" | jq -r '.destination')
        local helm_key=$(echo "$image_data" | jq -r '.helm_key')
        
        echo "📦 Processing: $repository_image -> $destination"
        
        # Check if image has a predefined tag
        if has_tag "$repository_image" "$images_json"; then
            local predefined_tag=$(echo "$image_data" | jq -r '.tag // empty')
            if [ -n "$predefined_tag" ]; then
                echo "🏷️  Using predefined tag: $predefined_tag"
                selected_tag="$predefined_tag"
            else
                selected_tag=""
            fi
        else
            selected_tag=""
        fi
        
        # If no predefined tag, fetch available tags
        if [ -z "$selected_tag" ]; then
            local available_tags=$(get_available_tags "$repository_image")
            
            if [ $? -eq 0 ] && [ -n "$available_tags" ]; then
                # Use the first tag (most recent by creation date)
                selected_tag=$(echo "$available_tags" | head -n1 | tr -d '[:space:]')
                echo "🏷️  Using fetched tag: $selected_tag"
            else
                if [ "$disable_date_based_tags" = true ]; then
                    echo "⚠️  Failed to fetch tags for $repository_image, using 'latest' as fallback"
                    selected_tag="latest"
                else
                    echo "⚠️  Failed to fetch tags for $repository_image, using date-based tag"
                    selected_tag="$date_based_tag"
                fi
                echo "🏷️  Using fallback tag: $selected_tag"
            fi
        fi
        
        # Copy the image
        if [ "$selected_tag" == "latest" ]; then
            # If using "latest" tag, copy with "latest" but tag destination appropriately
            if [ "$disable_date_based_tags" = true ]; then
                local dest_tag="latest"
                echo "🔄 Copying from latest tag, using 'latest' as destination tag"
            else
                local dest_tag="$date_based_tag"
                echo "🔄 Copying from latest tag, using date-based destination tag: $dest_tag"
            fi
            if copy_image "$repository_image" "latest" "$destination" "$dest_tag"; then
                # Update Helm values with the destination tag
                update_helm_values "$values_file" "$new_values_file" "$helm_key" "$dest_tag"
            else
                echo "❌ Failed to copy image: $repository_image:latest"
            fi
        else
            # Use the same tag for source and destination
            if copy_image "$repository_image" "$selected_tag" "$destination" "$selected_tag"; then
                # Update Helm values
                update_helm_values "$values_file" "$new_values_file" "$helm_key" "$selected_tag"
            else
                echo "❌ Failed to copy image: $repository_image:$selected_tag"
            fi
        fi
        
        echo "---"
    done
}

# Main execution
main() {
    local verbose=false
    local helm_chart_images_json="[]"
    local discovered_codecollection_images_json="[]"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            --no-date-tags)
                disable_date_based_tags=true
                shift
                ;;
            --date-tags)
                disable_date_based_tags=false
                shift
                ;;
            -c|--chart)
                chart_path="$2"
                shift 2
                ;;
            -e|--extra-images)
                extra_images_file="$2"
                shift 2
                ;;
            -b|--branch)
                codecollection_branch="$2"
                shift 2
                ;;
            -f|--values)
                values_file="$2"
                shift 2
                ;;
            -p|--prefix)
                destination_prefix="$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # Set verbose mode
    if [ "$verbose" = true ]; then
        set -x
    fi
    
    # Regenerate static image lists with current destination prefix
    runwhen_local_images=$(generate_runwhen_local_images)
    codecollection_images=$(generate_codecollection_images)
    
    # Check prerequisites
    check_prerequisites
    
    # Convert tag_exclusion_list to array if it's a string
    if [ -n "${tag_exclusion_list:-}" ] && [[ "$tag_exclusion_list" != *" "* ]]; then
        IFS=',' read -ra tag_exclusion_list <<< "$tag_exclusion_list"
    fi
    
    echo "🚀 Starting AWS ECR Registry Sync"
    echo "Registry: $private_registry"
    echo "Region: $aws_region"
    if [ -n "$values_file" ]; then
        echo "Values file: $values_file"
    else
        echo "Values file: None (will not update Helm values)"
    fi
    echo "Output file: $new_values_file"
    echo "Architecture: ${desired_architecture:-amd64}"
    echo "---"
    
    # Extract images from Helm chart if specified
    local helm_chart_images_json="[]"
    if [ -n "$chart_path" ]; then
        # Check if it's a local directory or a Helm repository reference
        if [ -d "$chart_path" ]; then
            echo "📦 Processing Helm chart from local directory: $chart_path"
            helm_chart_images_json=$(extract_helm_chart_images "$chart_path" "$values_file" "$extra_images_file")
        elif [[ "$chart_path" == *"/"* ]]; then
            echo "📦 Processing Helm chart from repository: $chart_path"
            helm_chart_images_json=$(extract_helm_chart_images "$chart_path" "$values_file" "$extra_images_file")
        else
            echo "❌ Invalid Helm chart path: $chart_path"
            echo "   Use either a local directory path or a repository reference (e.g., runwhen-contrib/runwhen-local)"
            exit 1
        fi
    fi
    
    # Discover CodeCollection images dynamically
    echo "🔍 Discovering CodeCollection images..."
    discovered_codecollection_images_json=$(discover_codecollection_images "$codecollection_branch" "$codecollection_registry_prefix")
    
    # Determine which images to sync based on what's available
    local use_helm_images=false
    local use_static_images=false
    
    # Check if Helm chart extraction was successful
    if [ -n "$helm_chart_images_json" ] && echo "$helm_chart_images_json" | jq -e . >/dev/null 2>&1; then
        local helm_count=$(echo "$helm_chart_images_json" | jq length 2>/dev/null || echo "0")
        if [ "$helm_count" -gt 0 ]; then
            use_helm_images=true
            echo "✅ Using Helm chart images ($helm_count images found)"
        fi
    fi
    
    # Check if dynamic CodeCollection discovery was successful
    local use_discovered_codecollections=false
    if [ -n "$discovered_codecollection_images_json" ] && echo "$discovered_codecollection_images_json" | jq -e . >/dev/null 2>&1; then
        local discovered_count=$(echo "$discovered_codecollection_images_json" | jq length 2>/dev/null || echo "0")
        if [ "$discovered_count" -gt 0 ]; then
            use_discovered_codecollections=true
            echo "✅ Using discovered CodeCollection images ($discovered_count images found)"
        fi
    fi
    
    # Use static images as fallback if dynamic discovery failed
    if [ "$use_helm_images" = false ]; then
        use_static_images=true
        echo "⚠️  Helm chart extraction failed or no images found, using static RunWhen Local images as fallback"
    fi
    
    if [ "$use_discovered_codecollections" = false ]; then
        echo "⚠️  CodeCollection discovery failed or no images found, using static CodeCollection images as fallback"
    fi
    
    # Sync images based on what's available
    if [ "$use_helm_images" = true ]; then
        sync_images "$helm_chart_images_json" "Helm Chart"
    elif [ "$use_static_images" = true ]; then
        # Sync RunWhen Local images (static fallback)
        if [ -n "${runwhen_local_images:-}" ]; then
            sync_images "$runwhen_local_images" "RunWhen Local (Static)"
        else
            echo "⚠️  No RunWhen Local images configured"
        fi
    fi
    
    # Sync CodeCollection images
    if [ "$use_discovered_codecollections" = true ]; then
        sync_images "$discovered_codecollection_images_json" "CodeCollection (Discovered)"
    else
        # Sync static CodeCollection images as fallback
        if [ -n "${codecollection_images:-}" ]; then
            sync_images "$codecollection_images" "CodeCollection (Static)"
        else
            echo "⚠️  No static CodeCollection images configured"
        fi
    fi
    
    echo "✅ AWS ECR Registry Sync completed"
    if [ -n "$values_file" ] && [ -f "$values_file" ]; then
        echo "📄 Updated Helm values saved to: $new_values_file"
    fi
    
    # Clean up temporary files
    rm -f rendered_chart.yaml helm_chart_images.txt
}

# Run main function
main "$@" 