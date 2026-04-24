#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# install_runner.sh — Install the runwhen-local runner helm chart
#
# Usage:
#   ./install_runner.sh \
#     --env-name       rwlight-67 \
#     --workspace-name ws-01 \
#     --runner-token   "<token>" \
#     --upload-info    ./uploadInfo.yaml \
#     --gcp-key        ./gcp.json \
#     [--values        ./values.yaml] \
#     [--ca-cert       ./platform-ca.crt]   # platform CA cert for runner TLS trust
#     [--kubeconfig    ./kubeconfig.yaml]
# ---------------------------------------------------------------------------

HELM_RELEASE="runwhen-local"
HELM_REPO_NAME="runwhen-contrib"
HELM_REPO_URL="https://runwhen-contrib.github.io/helm-charts"
HELM_CHART="${HELM_REPO_NAME}/runwhen-local"

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
ENV_NAME=""
WORKSPACE_NAME=""
RUNNER_TOKEN=""
UPLOAD_INFO_PATH=""
GCP_KEY_PATH=""
VALUES_FILE=""
CA_CERT_PATH=""
KUBECONFIG_PATH=""
INSECURE_SKIP_VERIFY=false
UNINSTALL=false

usage() {
    echo "Usage: $0 \\"
    echo "  --env-name       <env>        e.g. rwlight-67"
    echo "  --workspace-name <workspace>  e.g. ws-01"
    echo "  --runner-token   <token>      runner registration token"
    echo "  --upload-info    <path>       path to uploadInfo.yaml"
    echo "  --gcp-key        <path>       path to GCP service account JSON"
    echo "  [--values        <path>]      path to values.yaml (optional)"
    echo "  [--ca-cert            <path>]  path to platform CA cert (for local platform TLS)"
    echo "  [--insecure-skip-verify]       skip TLS verification on runner registration (alternative to --ca-cert)"
    echo "  [--kubeconfig         <path>]  path to kubeconfig yaml (optional; disables in-cluster auth)"
    echo "  [--uninstall]                 uninstall chart and delete namespace"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --env-name)        ENV_NAME="$2";         shift 2 ;;
        --workspace-name)  WORKSPACE_NAME="$2";   shift 2 ;;
        --runner-token)    RUNNER_TOKEN="$2";      shift 2 ;;
        --upload-info)     UPLOAD_INFO_PATH="$2";  shift 2 ;;
        --gcp-key)         GCP_KEY_PATH="$2";      shift 2 ;;
        --values)          VALUES_FILE="$2";       shift 2 ;;
        --ca-cert)              CA_CERT_PATH="$2";        shift 2 ;;
        --insecure-skip-verify) INSECURE_SKIP_VERIFY=true; shift ;;
        --kubeconfig)           KUBECONFIG_PATH="$2";     shift 2 ;;
        --uninstall)       UNINSTALL=true;         shift ;;
        -h|--help)         usage ;;
        *) echo "Unknown argument: $1"; usage ;;
    esac
done

# ---------------------------------------------------------------------------
# Validate required arguments
# ---------------------------------------------------------------------------
errors=()
[[ -z "$ENV_NAME" ]]        && errors+=("--env-name is required")
[[ -z "$WORKSPACE_NAME" ]]  && errors+=("--workspace-name is required")

if [[ "$UNINSTALL" == false ]]; then
    [[ -z "$RUNNER_TOKEN" ]]     && errors+=("--runner-token is required")
    [[ -z "$UPLOAD_INFO_PATH" ]] && errors+=("--upload-info is required")
    [[ -z "$GCP_KEY_PATH" ]]     && errors+=("--gcp-key is required")

    [[ -n "$UPLOAD_INFO_PATH" && ! -f "$UPLOAD_INFO_PATH" ]] && errors+=("uploadInfo file not found: $UPLOAD_INFO_PATH")
    [[ -n "$GCP_KEY_PATH"     && ! -f "$GCP_KEY_PATH" ]]     && errors+=("GCP key file not found: $GCP_KEY_PATH")
    [[ -n "$VALUES_FILE"      && ! -f "$VALUES_FILE" ]]       && errors+=("values file not found: $VALUES_FILE")
    [[ -n "$CA_CERT_PATH"     && ! -f "$CA_CERT_PATH" ]]      && errors+=("CA cert file not found: $CA_CERT_PATH")
    [[ -n "$KUBECONFIG_PATH"  && ! -f "$KUBECONFIG_PATH" ]]   && errors+=("kubeconfig file not found: $KUBECONFIG_PATH")
fi

if [[ ${#errors[@]} -gt 0 ]]; then
    for err in "${errors[@]}"; do echo "Error: $err"; done
    echo
    usage
fi

NAMESPACE="${ENV_NAME}-${WORKSPACE_NAME}"
CONTROL_ADDR="https://runner-control.${ENV_NAME}.local.runwhen.com"
# Routes through cortex-tenant proxy which injects X-Scope-OrgID from the workspace label
METRICS_ADDR="https://runner-metrics.${ENV_NAME}.local.runwhen.com/push"
CA_CONFIGMAP="${ENV_NAME}-runner-ca"

# ---------------------------------------------------------------------------
# Uninstall mode
# ---------------------------------------------------------------------------
if [[ "$UNINSTALL" == true ]]; then
    echo "=== Runner Uninstall ==="
    echo "  Namespace: $NAMESPACE"
    echo

    echo "→ Uninstalling helm release..."
    helm uninstall "$HELM_RELEASE" -n "$NAMESPACE" || echo "  (release not found, skipping)"

    echo "→ Deleting namespace $NAMESPACE..."
    kubectl delete namespace "$NAMESPACE" --wait=true

    echo
    echo "✅ Uninstall complete."
    exit 0
fi

echo "=== Runner Installation ==="
echo "  Namespace  : $NAMESPACE"
echo "  Control URL: $CONTROL_ADDR"
echo "  Metrics URL: $METRICS_ADDR"
echo "  Chart      : $HELM_CHART"
[[ -z "$CA_CERT_PATH" ]] && echo "  WARNING: --ca-cert not provided. Runner may fail TLS verification against a local platform."
echo

# ---------------------------------------------------------------------------
# 1. Add / update helm repo
# ---------------------------------------------------------------------------
echo "→ [1/6] Setting up Helm repo..."
if helm repo list 2>/dev/null | grep -q "^${HELM_REPO_NAME}"; then
    helm repo update "$HELM_REPO_NAME"
else
    helm repo add "$HELM_REPO_NAME" "$HELM_REPO_URL"
    helm repo update "$HELM_REPO_NAME"
fi

# ---------------------------------------------------------------------------
# 2. Process values.yaml — replace HARDCODED_WORKSPACE_NAME
# ---------------------------------------------------------------------------
VALUES_ARG=""
TEMP_VALUES=""

if [[ -n "$VALUES_FILE" ]]; then
    echo "→ [2/6] Substituting workspace name in values.yaml..."
    TEMP_VALUES=$(mktemp /tmp/values-XXXXXX.yaml)
    sed "s/HARDCODED_WORKSPACE_NAME/${WORKSPACE_NAME}/g" "$VALUES_FILE" > "$TEMP_VALUES"
    echo "  Workspace substitution done (temp: $TEMP_VALUES)"
    VALUES_ARG="-f ${TEMP_VALUES}"
else
    echo "→ [2/6] No values.yaml provided, using chart defaults."
fi

# ---------------------------------------------------------------------------
# 3. Create namespace
# ---------------------------------------------------------------------------
echo "→ [3/6] Creating namespace $NAMESPACE..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# ---------------------------------------------------------------------------
# 4. Create secrets and configmaps
# ---------------------------------------------------------------------------
echo "→ [4/6] Creating secrets..."

kubectl create secret generic uploadinfo \
    --from-file=uploadInfo.yaml="${UPLOAD_INFO_PATH}" \
    -n "$NAMESPACE" \
    --dry-run=client -o yaml | kubectl apply -f -
echo "  ✓ uploadinfo secret"

kubectl create secret generic runwhen-local-gcp \
    --from-file=GCPServiceAccountKeyWorkspaceBuilder.json="${GCP_KEY_PATH}" \
    -n "$NAMESPACE" \
    --dry-run=client -o yaml | kubectl apply -f -
echo "  ✓ runwhen-local-gcp secret"

kubectl create secret generic runner-registration-token \
    --from-literal=token="${RUNNER_TOKEN}" \
    -n "$NAMESPACE" \
    --dry-run=client -o yaml | kubectl apply -f -
echo "  ✓ runner-registration-token secret"

if [[ -n "$CA_CERT_PATH" ]]; then
    kubectl create configmap "${CA_CONFIGMAP}" \
        --from-file=ca.crt="${CA_CERT_PATH}" \
        -n "$NAMESPACE" \
        --dry-run=client -o yaml | kubectl apply -f -
    echo "  ✓ ${CA_CONFIGMAP} configmap"
fi

if [[ -n "$KUBECONFIG_PATH" ]]; then
    kubectl create secret generic kubeconfig \
        --from-file=kubeconfig="${KUBECONFIG_PATH}" \
        -n "$NAMESPACE" \
        --dry-run=client -o yaml | kubectl apply -f -
    echo "  ✓ kubeconfig secret"
fi

# ---------------------------------------------------------------------------
# 5. Helm install
# ---------------------------------------------------------------------------
# When --ca-cert is provided, wire it into the Helm proxyCA mechanism.
# This tells the runner chart to:
#   - Mount the CA in the runner pod at /etc/ssl/certs/proxy-ca.pem (Go system cert pool picks it up)
#   - Mount the CA in every worker pod and set REQUESTS_CA_BUNDLE / SSL_CERT_FILE / HTTP_PROXY_CA
# proxy.enabled=true is required to activate the proxyCA block in the runner configmap template.
PROXY_CA_ARGS=""
if [[ -n "$CA_CERT_PATH" ]]; then
    PROXY_CA_ARGS="\
        --set proxy.enabled=true \
        --set proxyCA.configMapName=${CA_CONFIGMAP} \
        --set proxyCA.key=ca.crt"
fi

KUBECONFIG_ARGS=""
if [[ -n "$KUBECONFIG_PATH" ]]; then
    KUBECONFIG_ARGS="\
        --set runwhenLocal.discoveryKubeconfig.inClusterAuth.enabled=false \
        --set runwhenLocal.discoveryKubeconfig.secretProvided.enabled=true \
        --set runwhenLocal.discoveryKubeconfig.secretProvided.secretKey=kubeconfig \
        --set runwhenLocal.discoveryKubeconfig.secretProvided.secretName=kubeconfig \
        --set runwhenLocal.discoveryKubeconfig.secretProvided.secretPath=kubeconfig \
        --set runwhenLocal.workspaceInfo.configMap.create=true \
        --set runwhenLocal.workspaceInfo.configMap.name=workspace-builder \
        --set runwhenLocal.workspaceInfo.configMap.data.cloudConfig.kubernetes.inClusterAuth=false \
        --set runwhenLocal.workspaceInfo.configMap.data.cloudConfig.kubernetes.kubeconfigFile=/shared/kubeconfig"
fi

echo "→ [5/7] Installing helm chart..."
helm upgrade --install "$HELM_RELEASE" "$HELM_CHART" \
    -n "$NAMESPACE" \
    ${VALUES_ARG} \
    --set workspaceName="${WORKSPACE_NAME}" \
    --set runwhenLocal.autoRun.uploadEnabled=true \
    --set runwhenLocal.uploadInfo.secretProvided.enabled=true \
    --set runwhenLocal.uploadInfo.secretProvided.secretName=uploadinfo \
    --set runwhenLocal.uploadInfo.secretProvided.secretKey=uploadInfo.yaml \
    --set runwhenLocal.uploadInfo.secretProvided.secretPath=uploadInfo.yaml \
    --set runner.enabled=true \
    --set runner.controlAddr="${CONTROL_ADDR}" \
    --set runner.metrics.url="${METRICS_ADDR}" \
    ${PROXY_CA_ARGS} \
    ${KUBECONFIG_ARGS}

# ---------------------------------------------------------------------------
# 6. Patch runner deployment with RUNNER_INSECURE_SKIP_VERIFY (optional)
# --ca-cert is handled entirely via Helm proxyCA values above:
#   - Runner pod: CA mounted at /etc/ssl/certs/proxy-ca.pem (Go system cert pool)
#   - Worker pods: CA mounted + REQUESTS_CA_BUNDLE / SSL_CERT_FILE / HTTP_PROXY_CA set
# --insecure-skip-verify is a fallback that skips TLS verification on the
#   runner → runner-control connection only (Go HTTP client, not workers).
# ---------------------------------------------------------------------------
if [[ "$INSECURE_SKIP_VERIFY" == true ]]; then
    echo "→ [6/7] Patching runner deployment with RUNNER_INSECURE_SKIP_VERIFY..."
    kubectl patch deployment runwhen-local-runner -n "$NAMESPACE" --type=json -p='[
      {
        "op": "add",
        "path": "/spec/template/spec/containers/0/env/-",
        "value": {
          "name": "RUNNER_INSECURE_SKIP_VERIFY",
          "value": "true"
        }
      }
    ]'
    echo "  ✓ RUNNER_INSECURE_SKIP_VERIFY=true"
else
    echo "→ [6/7] Skipping insecure-skip-verify patch"
fi

# ---------------------------------------------------------------------------
# 7. Fix otel-collector ca_file path
# The chart default proxyCA:{} is always truthy so the template renders
# ca_file: /etc/ssl/certs/proxy-ca.crt even when proxyCA is not set.
# Patch it to /tls/ca.crt which is already mounted from runner-metrics-tls.
# ---------------------------------------------------------------------------
echo "→ [7/7] Patching otel-collector configmap..."
CURRENT_CA=$(kubectl get configmap otel-collector -n "$NAMESPACE" -o jsonpath='{.data.relay}' 2>/dev/null | grep "ca_file" | awk '{print $2}' | tr -d '"')

if [[ "$CURRENT_CA" != "/tls/ca.crt" ]]; then
    RELAY=$(kubectl get configmap otel-collector -n "$NAMESPACE" -o jsonpath='{.data.relay}')
    RELAY_FIXED=$(echo "$RELAY" | sed 's|ca_file:.*|ca_file: "/tls/ca.crt"|g')
    kubectl create configmap otel-collector --from-literal=relay="$RELAY_FIXED" \
        -n "$NAMESPACE" --dry-run=client -o json | \
        kubectl patch configmap otel-collector -n "$NAMESPACE" --type=merge --patch-file=/dev/stdin
    kubectl rollout restart deployment/otel-collector -n "$NAMESPACE"
    echo "  ✓ ca_file path corrected and otel-collector restarted"
else
    echo "  ✓ ca_file path already correct, no patch needed"
fi

# ---------------------------------------------------------------------------
# Cleanup temp files
# ---------------------------------------------------------------------------
[[ -n "$TEMP_VALUES" && -f "$TEMP_VALUES" ]] && rm -f "$TEMP_VALUES"

echo
echo "✅ Done. Runner installed in namespace: $NAMESPACE"
echo "   NOTE: otel-collector requires 'runner-metrics-tls' secret to be provisioned by the platform."
echo "   Check status: kubectl get pods -n $NAMESPACE"
