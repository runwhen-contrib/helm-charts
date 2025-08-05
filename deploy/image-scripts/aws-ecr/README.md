# AWS ECR Registry Sync Script

## Overview

The `sync_to_aws_ecr.sh` script is a comprehensive tool for syncing container images from RunWhen registries to AWS ECR (Elastic Container Registry). It supports both static image lists and dynamic discovery from Helm charts and CodeCollection repositories.

## Features

- **Dynamic Image Discovery**: Extract images from Helm charts and CodeCollection repositories
- **Static Image Lists**: Fallback to predefined image lists when dynamic discovery isn't available
- **Multi-Registry Support**: Sync images from Docker Hub, GitHub Container Registry, Google Artifact Registry, and more
- **Tag Management**: Fetch the most recent tags or use predefined tags (default: use same tag as source)
- **Helm Integration**: Update Helm values files with new image tags
- **Daemonless Copying**: Use Docker Buildx for efficient image copying without requiring a Docker daemon
- **Configurable Destinations**: Easy customization of ECR repository paths
- **Intelligent Fallbacks**: Automatic fallback to static lists when dynamic discovery fails

## Prerequisites

### Required Tools
- `jq` - JSON processor
- `yq` - YAML processor
- `aws` - AWS CLI
- `docker` - Docker with buildx support
- `curl` - HTTP client
- `helm` - Helm CLI (for chart processing)

### AWS Configuration
- AWS credentials configured (via `aws configure` or environment variables)
- Appropriate ECR permissions
- ECR registry URL configured in the script

## Configuration

### Script Variables
Edit the variables at the top of the script:

```bash
# AWS ECR Configuration
private_registry="982534371594.dkr.ecr.us-west-2.amazonaws.com"
aws_region="us-west-2"

# Architecture
desired_architecture="amd64"

# Destination Configuration
destination_prefix="test-rwl-runwhen"  # ECR repository prefix

# Helm Configuration
values_file=""  # Path to Helm values file (optional)
new_values_file="updated_values.yaml"

# Chart Configuration
chart_path="runwhen-contrib/runwhen-local"  # Default Helm chart
extra_images_file=""  # Additional images file
codecollection_branch="main"
codecollection_registry_prefix="us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images"
```

### Static Image Lists
The script includes fallback static image lists for when dynamic discovery fails. These are automatically generated using the configured `destination_prefix`:

#### RunWhen Local Images
```json
[
  {
    "repository_image": "ghcr.io/runwhen-contrib/runwhen-local",
    "destination": "test-rwl-runwhen/runwhen-local",
    "helm_key": "runwhenLocal"
  },
  {
    "repository_image": "us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner",
    "destination": "test-rwl-runwhen/runner",
    "helm_key": "runner"
  },
  {
    "repository_image": "docker.io/otel/opentelemetry-collector",
    "destination": "test-rwl-runwhen/opentelemetry-collector",
    "helm_key": "opentelemetry/collector"
  }
]
```

#### CodeCollection Images
```json
[
  {
    "repository_image": "us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/runwhen-contrib-rw-cli-codecollection-main",
    "destination": "test-rwl-runwhen/runwhen-contrib-rw-cli-codecollection-main",
    "helm_key": "runner.runEnvironment"
  }
  // ... more images
]
```

## Usage

### Basic Usage
```bash
# Sync with default configuration (uses same tag as source)
./sync_to_aws_ecr.sh

# Enable date-based tags
./sync_to_aws_ecr.sh --date-tags

# Enable verbose output
./sync_to_aws_ecr.sh -v
```

### Advanced Usage
```bash
# Use specific Helm chart with values file
./sync_to_aws_ecr.sh -c ./charts/runwhen-local -f values.yaml

# Add extra images from file
./sync_to_aws_ecr.sh -c ./charts/runwhen-local -f values.yaml -e extra-images.txt

# Use different CodeCollection branch
./sync_to_aws_ecr.sh -b develop

# Use custom destination prefix
./sync_to_aws_ecr.sh -p my-company/runwhen

# Combine multiple options
./sync_to_aws_ecr.sh --date-tags -c runwhen-contrib/runwhen-local -f values.yaml -v
```

### Command Line Options
- `-h, --help`: Show help message
- `-v, --verbose`: Enable verbose output
- `--date-tags`: Enable date-based tags (default: use same tag as source)
- `-c, --chart PATH`: Path to Helm chart directory or repository reference
- `-e, --extra-images FILE`: Path to file containing additional images
- `-b, --branch BRANCH`: CodeCollection branch to use (default: main)
- `-f, --values FILE`: Helm values file to use for chart rendering and updates
- `-p, --prefix PREFIX`: Destination prefix for ECR repositories (default: test-rwl-runwhen)

## How It Works

### 1. Image Discovery
The script uses multiple methods to discover images:

#### Helm Chart Extraction
- Renders Helm chart to YAML using `helm template`
- Extracts image references using `yq`
- Processes additional images from extra images file
- Creates JSON structure with repository, destination, and tag information
- Uses proper destination path generation (removes registry prefixes)

#### CodeCollection Discovery
- Downloads `codecollections.yaml` from GitHub
- Extracts organization and repository names from git URLs
- Constructs image names using the configured registry prefix
- Fetches the most recent tags for each image
- Uses configurable destination prefix for ECR paths

### 2. Fallback Logic
The script implements intelligent fallback:
- If Helm chart extraction succeeds → Use Helm chart images
- If Helm chart extraction fails → Use static RunWhen Local images
- If CodeCollection discovery succeeds → Use discovered images
- If CodeCollection discovery fails → Use static CodeCollection images

### 3. Image Processing
For each discovered image:
1. **Tag Selection**: Use predefined tag or fetch most recent tag
2. **ECR Repository Creation**: Create ECR repository if it doesn't exist
3. **Authentication**: Authenticate with ECR using AWS credentials
4. **Image Copy**: Use Docker Buildx to copy image to ECR
5. **Helm Values Update**: Update Helm values file with new tags (if configured)

### 4. Destination Path Generation
Images are copied to ECR with consistent naming using the configured prefix:
- Source: `ghcr.io/runwhen-contrib/runwhen-local`
- Destination: `test-rwl-runwhen/runwhen-local` (or custom prefix)

## Examples

### Example 1: Basic Sync
```bash
./sync_to_aws_ecr.sh
```
This will:
- Extract images from the default Helm chart (`runwhen-contrib/runwhen-local`)
- Discover CodeCollection images from the main branch
- Copy all images to ECR with the same tags as source (default behavior)
- Update Helm values file if configured

### Example 2: Custom Chart with Values
```bash
./sync_to_aws_ecr.sh -c ./my-chart -f my-values.yaml -e extra-images.txt
```
This will:
- Extract images from `./my-chart` using `my-values.yaml`
- Add images from `extra-images.txt`
- Discover CodeCollection images
- Copy all images to ECR with same tags as source

### Example 3: Fallback to Static Lists
```bash
./sync_to_aws_ecr.sh -c ""
```
This will:
- Skip Helm chart extraction (empty chart path)
- Use static RunWhen Local images as fallback
- Use static CodeCollection images as fallback
- Copy images to ECR with same tags as source

### Example 4: Custom Destination Prefix
```bash
./sync_to_aws_ecr.sh -p my-company/runwhen
```
This will:
- Use `my-company/runwhen` as the destination prefix
- All images will be copied to ECR with paths like:
  - `my-company/runwhen/runwhen-local`
  - `my-company/runwhen/runner`
  - `my-company/runwhen/opentelemetry-collector`

### Example 5: Date-Based Tags
```bash
./sync_to_aws_ecr.sh --date-tags
```
This will:
- Use date-based tags (YYYYMMDDHHMMSS format) for destination images
- Useful for creating timestamped image versions
- Source images still use their original tags

## Output

### Console Output
The script provides detailed progress information:
```
🚀 Starting AWS ECR Registry Sync
Registry: 982534371594.dkr.ecr.us-west-2.amazonaws.com
Region: us-west-2
---
📦 Processing Helm chart from repository: runwhen-contrib/runwhen-local
🔍 Discovering CodeCollection images...
✅ Using Helm chart images (3 images found)
✅ Using discovered CodeCollection images (7 images found)
🔄 Starting sync for Helm Chart images...
📦 Processing: ghcr.io/runwhen-contrib/runwhen-local -> test-rwl-runwhen/runwhen-local
🏷️  Using predefined tag: latest
Copying image: ghcr.io/runwhen-contrib/runwhen-local:latest to 982534371594.dkr.ecr.us-west-2.amazonaws.com/test-rwl-runwhen/runwhen-local:latest
✅ Successfully copied image using docker buildx
---
✅ AWS ECR Registry Sync completed
```

### Generated Files
- `updated_values.yaml`: Updated Helm values file with new image tags
- `rendered_chart.yaml`: Temporary Helm chart rendering output
- `helm_chart_images.txt`: Temporary list of extracted images

## Error Handling

The script includes comprehensive error handling:
- **Prerequisites Check**: Validates all required tools are available
- **Network Failures**: Handles connectivity issues gracefully
- **Authentication Failures**: Provides clear error messages for AWS credential issues
- **Image Copy Failures**: Continues processing other images if one fails
- **JSON Validation**: Validates JSON output from discovery functions
- **AWS CLI Pager**: Disables pager usage to prevent "less" program errors

## Troubleshooting

### Common Issues

#### AWS Credentials Not Found
```
Unable to locate credentials. You can configure credentials by running "aws configure"
```
**Solution**: Configure AWS credentials using `aws configure` or set environment variables.

#### Docker Buildx Not Available
```
❌ Docker buildx not available. Please install Docker buildx plugin.
```
**Solution**: Install Docker Buildx plugin or update Docker to a version that includes it.

#### Helm Chart Not Found
```
❌ Invalid Helm chart path: invalid-chart
```
**Solution**: Ensure the chart path is correct and the Helm repository is added.

#### Image Copy Failures
```
❌ Failed to copy image using docker buildx
```
**Solution**: Check network connectivity, image accessibility, and AWS permissions.

#### Double Tag Issues
```
❌ Failed to copy image: repository:tag:tag
```
**Solution**: This was fixed in recent versions. Update to the latest script version.

### Debug Mode
Enable verbose output to see detailed execution:
```bash
./sync_to_aws_ecr.sh -v
```

## Security Considerations

- **AWS Credentials**: Store credentials securely using AWS IAM roles or environment variables
- **Image Sources**: Verify image sources are trusted before syncing
- **ECR Permissions**: Use least-privilege IAM policies for ECR access
- **Network Security**: Ensure secure network connectivity to source registries

## Recent Improvements

### Version 2.0+ Features
- **Default Tag Behavior**: Now uses same tags as source by default (more predictable)
- **Configurable Destinations**: Easy customization of ECR repository paths
- **Improved Fallback Logic**: Better handling when dynamic discovery fails
- **Fixed Double Tags**: Resolved issues with malformed image references
- **AWS CLI Compatibility**: Fixed pager-related errors
- **Enhanced Error Handling**: Better validation and error messages

## Contributing

When modifying the script:
1. Test with both dynamic discovery and static fallbacks
2. Validate JSON output from discovery functions
3. Ensure proper error handling for all failure scenarios
4. Update this README for any new features or changes
5. Test destination prefix customization
6. Verify tag handling behavior

## License

This script is part of the RunWhen project and follows the project's licensing terms. 