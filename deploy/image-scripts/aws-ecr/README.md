# AWS ECR Registry Sync Script

## Overview

The `sync_to_aws_ecr.sh` script is a comprehensive tool for syncing container images from RunWhen registries to AWS ECR (Elastic Container Registry). It supports both static image lists and dynamic discovery from Helm charts and CodeCollection repositories.

## Features

- **Dynamic Image Discovery**: Extract images from Helm charts and CodeCollection repositories
- **Static Image Lists**: Fallback to predefined image lists when dynamic discovery isn't available
- **Multi-Registry Support**: Sync images from Docker Hub, GitHub Container Registry, Google Artifact Registry, and more
- **Tag Management**: Fetch the most recent tags or use predefined tags (default: use same tag as source)
- **Automatic Repository Setup**: Automatically adds required Helm repositories (runwhen-contrib, open-telemetry)
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
destination_prefix="test-rwl-runwhen2"  # ECR repository prefix

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
    "destination": "test-rwl-runwhen2/runwhen-local",
    "helm_key": "runwhenLocal"
  },
  {
    "repository_image": "us-docker.pkg.dev/runwhen-nonprod-shared/public-images/runner",
    "destination": "test-rwl-runwhen2/runner",
    "helm_key": "runner"
  },
  {
    "repository_image": "docker.io/otel/opentelemetry-collector",
    "destination": "test-rwl-runwhen2/opentelemetry-collector",
    "helm_key": "opentelemetry/collector"
  }
]
```

#### CodeCollection Images
```json
[
  {
    "repository_image": "us-west1-docker.pkg.dev/runwhen-nonprod-beta/public-images/runwhen-contrib-rw-cli-codecollection-main",
    "destination": "test-rwl-runwhen2/runwhen-contrib-rw-cli-codecollection-main",
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

# Sync with date-based tags
./sync_to_aws_ecr.sh --date-tags

# Sync with custom destination prefix
./sync_to_aws_ecr.sh -p my-custom-prefix

# Sync with verbose output
./sync_to_aws_ecr.sh -v
```

### Advanced Usage
```bash
# Extract images from a specific Helm chart
./sync_to_aws_ecr.sh -c ./charts/my-chart

# Extract images from a Helm repository chart
./sync_to_aws_ecr.sh -c runwhen-contrib/runwhen-local

# Add extra images from a file
./sync_to_aws_ecr.sh -e extra-images.txt

# Use a different CodeCollection branch
./sync_to_aws_ecr.sh -b develop

# Combine multiple options
./sync_to_aws_ecr.sh -c runwhen-contrib/runwhen-local -p production-images -v
```

## Command Line Options

| Option | Description | Default |
|--------|-------------|---------|
| `-h, --help` | Show help message | - |
| `-v, --verbose` | Enable verbose output | false |
| `--date-tags` | Enable date-based tags | false (uses source tags) |
| `--no-date-tags` | Disable date-based tags | true |
| `-c, --chart PATH` | Path to Helm chart directory or repository reference | `runwhen-contrib/runwhen-local` |
| `-e, --extra-images FILE` | Path to file containing additional images | - |
| `-b, --branch BRANCH` | CodeCollection branch to use | `main` |
| `-p, --prefix PREFIX` | Destination prefix for ECR repositories | `test-rwl-runwhen2` |

## How It Works

### 1. Image Discovery
The script uses multiple methods to discover images:

1. **Helm Chart Extraction**: Renders the specified Helm chart and extracts all image references
2. **Dynamic CodeCollection Discovery**: Fetches `codecollections.yaml` from GitHub and constructs image names
3. **Static Fallbacks**: Uses predefined image lists if dynamic discovery fails

### 2. Repository Setup
- Automatically adds required Helm repositories (`runwhen-contrib`, `open-telemetry`)
- Updates repositories to ensure latest chart versions are available

### 3. Tag Management
- Fetches available tags from source registries
- Uses the most recent tag by creation date
- Falls back to `latest` if tag fetching fails
- Supports date-based tagging for tracking purposes

### 4. Image Syncing
- Creates ECR repositories if they don't exist
- Authenticates with AWS ECR
- Copies images using Docker Buildx (daemonless)
- Handles multi-architecture images

## Recent Improvements

### Latest Changes
- **Removed Helm Values Updates**: Simplified script by removing Helm values file update functionality
- **Automatic Repository Setup**: Script now automatically adds required Helm repositories
- **Improved Error Handling**: Better fallback logic and error messages
- **Fixed Double Tags**: Resolved issue with duplicate tags in image paths
- **AWS CLI Compatibility**: Added `--no-cli-pager` flags for better compatibility
- **Configurable Destinations**: Made destination paths easily configurable via `-p` option

### Previous Enhancements
- **Dynamic Image Discovery**: Extract images directly from Helm charts
- **CodeCollection Integration**: Discover runtime images from GitHub repository
- **Tag Fetching**: Automatically fetch most recent tags from source registries
- **Multi-Registry Support**: Support for Docker Hub, GitHub Container Registry, Google Artifact Registry
- **Daemonless Copying**: Use Docker Buildx for efficient image operations

## Troubleshooting

### Common Issues

#### Helm Chart Not Found
```
❌ Helm chart path does not exist: runwhen-contrib/runwhen-local
```
**Solution**: The script will automatically add the required Helm repositories. If issues persist, manually run:
```bash
helm repo add runwhen-contrib https://runwhen-contrib.github.io/helm-charts
helm repo update
```

#### Authentication Errors
```
❌ Failed to get ECR authentication token
```
**Solution**: Ensure AWS credentials are configured:
```bash
aws configure
# or set environment variables
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
```

#### Image Copy Failures
```
❌ Failed to copy image using docker buildx
```
**Solution**: Check network connectivity, source image availability, and AWS ECR permissions.

#### No Images Discovered
```
⚠️ Helm chart extraction failed or no images found, using static RunWhen Local images as fallback
```
**Solution**: This is normal fallback behavior. The script will use static image lists when dynamic discovery fails.

### Debug Mode
Enable verbose output to see detailed execution:
```bash
./sync_to_aws_ecr.sh -v
```

## Examples

### Production Deployment
```bash
# Sync images for production with custom prefix
./sync_to_aws_ecr.sh \
  -c runwhen-contrib/runwhen-local \
  -p production-runwhen \
  --date-tags \
  -v
```

### Development Testing
```bash
# Quick test with default settings
./sync_to_aws_ecr.sh

# Test with different branch
./sync_to_aws_ecr.sh -b develop -p dev-test
```

### Custom Image Set
```bash
# Create a file with additional images
echo "ghcr.io/my-org/my-image:latest" > extra-images.txt

# Sync with custom images
./sync_to_aws_ecr.sh -e extra-images.txt -p custom-images
```

## File Structure

```
deploy/image-scripts/aws-ecr/
├── sync_to_aws_ecr.sh          # Main script
├── README.md                   # This documentation
└── values.yaml                 # Sample Helm values file (for reference)
```

## Contributing

When modifying the script:

1. **Test thoroughly** with different chart types and configurations
2. **Update documentation** to reflect any changes
3. **Maintain backward compatibility** where possible
4. **Add error handling** for new features
5. **Update examples** to demonstrate new functionality

## Support

For issues or questions:
1. Check the troubleshooting section
2. Enable verbose mode for detailed debugging
3. Review the script configuration
4. Ensure all prerequisites are met 