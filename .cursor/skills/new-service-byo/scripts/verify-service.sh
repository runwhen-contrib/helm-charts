#!/usr/bin/env bash
#
# verify-service.sh — Run the enterprise BYO checklist over a runwhen-local
# chart template (or a dependent subchart's pod-bearing template).
#
# Usage:
#   verify-service.sh <template-path>
#   verify-service.sh --subchart <subchart-name> [<subchart-template>]
#
# Examples:
#   verify-service.sh charts/runwhen-local/templates/runner-deployment.yaml
#   verify-service.sh --subchart opentelemetry-collector
#   verify-service.sh --subchart opentelemetry-collector templates/deployment.yaml
#
# Renders the template under four matrices (defaults, hardened security,
# proxy + proxyCA enabled, registryOverride) plus — when --subchart is set
# — a fifth subchart-overlay matrix that verifies operator-supplied
# additionalLabels / podLabels / podAnnotations / podSecurityContext /
# image.repository land on the rendered subchart resources. Exits 0 = clean.
#
# Run from the repo root (helm-charts/).

set -euo pipefail

usage() {
  echo "Usage: $0 <template-path>" >&2
  echo "       $0 --subchart <subchart-name> [<subchart-template>]" >&2
  exit 2
}

CHART_DIR="charts/runwhen-local"
SUBCHART=""
SUBCHART_DEFAULT_TMPL="templates/deployment.yaml"
TEMPLATE=""

if [[ $# -lt 1 || $# -gt 3 ]]; then usage; fi

if [[ "$1" == "--subchart" ]]; then
  if [[ $# -lt 2 ]]; then usage; fi
  SUBCHART="$2"
  SUBCHART_TMPL="${3:-$SUBCHART_DEFAULT_TMPL}"
  # Resolve the subchart's tarball / unpacked dir under runwhen-local.
  shopt -s nullglob
  _matches=("$CHART_DIR/charts/$SUBCHART" "$CHART_DIR/charts/$SUBCHART"-*.tgz)
  shopt -u nullglob
  if [[ ${#_matches[@]} -eq 0 ]]; then
    echo "ERROR: subchart '$SUBCHART' not found under $CHART_DIR/charts/" >&2
    echo "       (expected $CHART_DIR/charts/$SUBCHART/ or $CHART_DIR/charts/$SUBCHART-<version>.tgz)" >&2
    exit 2
  fi
  SHOW_ONLY="charts/$SUBCHART/$SUBCHART_TMPL"
  TEMPLATE="$CHART_DIR/$SHOW_ONLY"
  echo "Verifying subchart: $SUBCHART (template: $SUBCHART_TMPL)"
else
  TEMPLATE="$1"
  if [[ ! -f "$TEMPLATE" ]]; then
    echo "ERROR: $TEMPLATE not found" >&2
    exit 2
  fi
  SHOW_ONLY="${TEMPLATE#"$CHART_DIR"/}"
fi

# Helm matrices ----------------------------------------------------------------
# Use sentinel `--set _placeholder=true` so empty arrays don't trip `set -u`
# on bash 3.2 (the macOS default).
HELM_DEFAULTS=(--set "_placeholder=true")

# Hardened pod / container SecurityContext via the existing helpers.
# These are the default container values, plus a podSecurityContext that
# matches what `runwhen-platform` ships; both should pass through the
# `runwhen-local.{pod,container}SecurityContext` helpers.
HELM_HARDENED=(
  --set 'podSecurityContext.runAsNonRoot=true'
  --set 'podSecurityContext.fsGroup=1000'
  --set 'podSecurityContext.seccompProfile.type=RuntimeDefault'
  --set 'containerSecurityContext.allowPrivilegeEscalation=false'
  --set 'containerSecurityContext.readOnlyRootFilesystem=true'
  --set 'containerSecurityContext.capabilities.drop[0]=ALL'
  --set 'containerSecurityContext.seccompProfile.type=RuntimeDefault'
)

HELM_PROXY=(
  --set 'proxy.enabled=true'
  --set 'proxy.httpProxy=http://proxy.example.com:8080'
  --set 'proxy.httpsProxy=http://proxy.example.com:8080'
  --set-string 'proxy.noProxy=127.0.0.1\,localhost'
  --set 'proxyCA.secretName=corp-ca-bundle'
  --set 'proxyCA.key=ca.crt'
)

HELM_REGISTRY=(
  --set 'registryOverride=artifactory.example.com'
)

# Subchart overlay matrix (only used when --subchart is set). Drives the
# subchart's own knobs via the parent chart's nested values block.
HELM_SUBCHART_OVERLAY=()
if [[ -n "$SUBCHART" ]]; then
  HELM_SUBCHART_OVERLAY=(
    --set "${SUBCHART}.additionalLabels.cost-center=platform-eng"
    --set "${SUBCHART}.podLabels.policy/enforce=baseline"
    --set "${SUBCHART}.podAnnotations.linkerd\\.io/inject=enabled"
    --set "${SUBCHART}.podSecurityContext.runAsNonRoot=true"
    --set "${SUBCHART}.podSecurityContext.fsGroup=1000"
    --set "${SUBCHART}.podSecurityContext.seccompProfile.type=RuntimeDefault"
    --set-string "${SUBCHART}.image.repository=artifactory.example.com/dockerhub/otel/opentelemetry-collector"
    --set "${SUBCHART}.image.tag=0.127.0"
    --set "${SUBCHART}.serviceAccount.automountServiceAccountToken=false"
  )
fi

# -----------------------------------------------------------------------------

# Track failures
FAIL=0
mark() {
  local status="$1" label="$2"
  if [[ "$status" == "ok" ]]; then
    printf "  \033[32m✓\033[0m %s\n" "$label"
  else
    printf "  \033[31m✗\033[0m %s\n" "$label"
    FAIL=$((FAIL+1))
  fi
}

# render_to_tmp <matrix-label> <helm-args...>
#
# Renders the target template under the given matrix. On success, sets the
# global RENDERED_PATH to the tmp-file path and returns 0. On failure, surfaces
# helm's stderr, increments FAIL, sets RENDERED_PATH="", and returns 1 so the
# script ALWAYS exits non-zero — the previous version swallowed `helm template`
# errors via `2>/dev/null` and `|| HARD_OUT=""`, which let a failed render
# render a green "OK" exit.
#
# WHY A GLOBAL VAR INSTEAD OF STDOUT: callers used to do
# `OUT=$(render_to_tmp …)`, which spawns a SUBSHELL for command substitution.
# Any FAIL increment inside the subshell is lost when it exits, so even a
# non-zero return from the helper produced exit-code 0 for the script overall.
# Writing to a global variable keeps the helper running in the parent shell
# where FAIL increments persist. All call sites that intentionally skip a
# matrix gate BEFORE this helper, so by the time we get here a render error
# is always a real bug.
RENDERED_PATH=""
render_to_tmp() {
  local label="$1"; shift
  local out err
  out=$(mktemp)
  err=$(mktemp)
  RENDERED_PATH=""
  if helm template rw "$CHART_DIR" "$@" --show-only "$SHOW_ONLY" >"$out" 2>"$err"; then
    rm -f "$err"
    RENDERED_PATH="$out"
    return 0
  fi
  printf "  \033[31m✗\033[0m Matrix '%s': helm template failed to render — full error below:\n" "$label" >&2
  sed 's/^/      /' "$err" >&2
  rm -f "$out" "$err"
  FAIL=$((FAIL+1))
  return 1
}

# Look for a literal pattern in a file.
needs() {
  local file="$1" pattern="$2" label="$3"
  if grep -F -e "$pattern" -- "$file" >/dev/null 2>&1; then mark ok "$label"; else mark fail "$label"; fi
}

# Look for a regex in a file.
needs_re() {
  local file="$1" pattern="$2" label="$3"
  if grep -E -e "$pattern" -- "$file" >/dev/null 2>&1; then mark ok "$label"; else mark fail "$label"; fi
}

# Pattern must NOT be present.
needs_absent() {
  local file="$1" pattern="$2" label="$3"
  if grep -F -e "$pattern" -- "$file" >/dev/null 2>&1; then mark fail "$label"; else mark ok "$label"; fi
}

# === Matrix 1: defaults ====================================================
echo ""
echo "============================================================"
echo "Matrix 1: defaults"
echo "============================================================"
if [[ -n "$SUBCHART" ]]; then
  echo "  (subchart mode — Matrix 1 limited to subchart sanity checks)"
  render_to_tmp defaults "${HELM_DEFAULTS[@]}" || true
  DEFAULT_OUT="$RENDERED_PATH"
  if [[ -n "$DEFAULT_OUT" ]]; then
    WORKLOAD_KIND=$(awk '/^kind: / {print $2; exit}' "$DEFAULT_OUT" 2>/dev/null || echo "")
    echo "  Detected kind: ${WORKLOAD_KIND:-<unknown>}"
    needs "$DEFAULT_OUT" "app.kubernetes.io/instance: rw" "subchart inherits release name (app.kubernetes.io/instance)"
    # Subchart-default hardening sanity — the bundled OTel subchart ships
    # `securityContext: {}` (empty) at pod level by default. Flag it so the
    # parent chart's values.yaml owns the hardened defaults instead.
    if grep -E "^[[:space:]]+securityContext:[[:space:]]*$" "$DEFAULT_OUT" | head -1 | grep -q . && \
       grep -A1 "^[[:space:]]\+securityContext:[[:space:]]*$" "$DEFAULT_OUT" | grep -qE "^[[:space:]]+\{\}"; then
      mark fail "subchart pod-level securityContext is empty by default — parent values should set podSecurityContext"
    else
      mark ok "subchart pod-level securityContext non-empty (parent overrides applied)"
    fi
    rm -f "$DEFAULT_OUT"
  fi
  # Skip Matrix 2-4 entirely for subcharts.
  echo ""
  echo "============================================================"
  echo "Matrix 2-4: skipped (parent-chart checks; not applicable to subchart)"
  echo "============================================================"
  WORKLOAD_KIND="${WORKLOAD_KIND:-}"
  goto_matrix5=1
else
  goto_matrix5=0
fi

if [[ "$goto_matrix5" -eq 0 ]]; then
render_to_tmp defaults "${HELM_DEFAULTS[@]}" || true
DEFAULT_OUT="$RENDERED_PATH"
if [[ -z "$DEFAULT_OUT" ]]; then
  echo "  (skipping default-render assertions — render_to_tmp marked Matrix 1 failed)"
fi

WORKLOAD_KIND=""
if [[ -n "$DEFAULT_OUT" ]]; then
  echo "  Rendered: $(wc -l <"$DEFAULT_OUT") lines"

  WORKLOAD_KIND=$(awk '/^kind: / {print $2; exit}' "$DEFAULT_OUT" 2>/dev/null || echo "")
  echo "  Detected kind: ${WORKLOAD_KIND:-<unknown>}"

  # Standard chart labels (from runwhen-local.labels)
  needs "$DEFAULT_OUT" "helm.sh/chart: runwhen-local" "runwhen-local.labels rendered (helm.sh/chart present)"
  needs_re "$DEFAULT_OUT" "app.kubernetes.io/name: (runwhen-local|rw-runwhen-local-(workspace-builder|runner))" "app.kubernetes.io/name set"
  needs "$DEFAULT_OUT" "app.kubernetes.io/instance: rw" "app.kubernetes.io/instance set"
  needs "$DEFAULT_OUT" "app.kubernetes.io/managed-by: Helm" "managed-by set"
  needs_re "$DEFAULT_OUT" "app.kubernetes.io/component: [a-z0-9-]+" "component label set"

  case "$WORKLOAD_KIND" in
    Deployment|StatefulSet|DaemonSet|ReplicaSet)
      needs_re "$DEFAULT_OUT" "matchLabels:" "spec.selector.matchLabels present (selector helper)"
      ;;
    Job|CronJob)
      mark ok "spec.selector skipped — not applicable to ${WORKLOAD_KIND}"
      ;;
    Service|ConfigMap|ServiceAccount|Secret|Role|RoleBinding|ClusterRole|ClusterRoleBinding|Ingress)
      mark ok "selector check skipped — kind=${WORKLOAD_KIND}"
      ;;
    *)
      mark ok "selector check skipped — kind=${WORKLOAD_KIND:-unknown}"
      ;;
  esac

  # Resource name MUST be release-prefixed (allow `rw` release name as the prefix).
  if grep -E -e "^  name: rw(-|\$)" -- "$DEFAULT_OUT" >/dev/null 2>&1; then
    mark ok "resource name uses runwhen-local.fullname / release-prefixed"
  else
    mark fail "resource name is not release-prefixed (collides if two releases share a namespace)"
  fi

  # ServiceAccount referenced by pods should be release-prefixed too.
  if grep -E "^[[:space:]]+serviceAccountName:" -- "$DEFAULT_OUT" >/dev/null 2>&1; then
    if grep -E "^[[:space:]]+serviceAccountName: rw(-|\$)" -- "$DEFAULT_OUT" >/dev/null 2>&1; then
      mark ok "serviceAccountName is release-prefixed"
    else
      mark fail "serviceAccountName is hardcoded (e.g. 'runner' / 'workspace-builder') — collides on second release"
    fi
  fi

  # No proxy env / proxyCA volume by default.
  needs_absent "$DEFAULT_OUT" "name: HTTP_PROXY" "HTTP_PROXY absent by default"
  needs_absent "$DEFAULT_OUT" "name: proxy-ca" "proxy-ca volume absent by default"
  needs_absent "$DEFAULT_OUT" "SSL_CERT_FILE" "SSL_CERT_FILE absent by default"

  rm -f "$DEFAULT_OUT"
fi

# Pod-bearing kinds — Matrix 2 (securityContext) and Matrix 3 (proxy env)
# only make sense on these. Skip on Services / ConfigMaps / Secrets / RBAC.
is_pod_bearing() {
  case "$1" in
    Deployment|StatefulSet|DaemonSet|ReplicaSet|Job|CronJob|Pod) return 0 ;;
    *) return 1 ;;
  esac
}

# === Matrix 2: hardened SecurityContext ===================================
echo ""
echo "============================================================"
echo "Matrix 2: hardened SecurityContext via runwhen-local helpers"
echo "============================================================"

if ! is_pod_bearing "$WORKLOAD_KIND"; then
  echo "  (skipping — kind=${WORKLOAD_KIND:-unknown} has no pod spec)"
  mark ok "Matrix 2 skipped — kind=${WORKLOAD_KIND:-unknown}"
  HARD_OUT=""
else
  render_to_tmp hardened "${HELM_HARDENED[@]}" || true
  HARD_OUT="$RENDERED_PATH"
fi

if [[ -n "$HARD_OUT" ]]; then
  needs "$HARD_OUT" "runAsNonRoot: true" "podSecurityContext: runAsNonRoot honoured"
  needs "$HARD_OUT" "fsGroup: 1000" "podSecurityContext: fsGroup honoured"
  needs "$HARD_OUT" "type: RuntimeDefault" "seccompProfile RuntimeDefault honoured"
  needs "$HARD_OUT" "allowPrivilegeEscalation: false" "containerSecurityContext: allowPrivilegeEscalation honoured"
  needs "$HARD_OUT" "readOnlyRootFilesystem: true" "containerSecurityContext: readOnlyRootFilesystem honoured"
  needs_re "$HARD_OUT" "^[[:space:]]+- ALL$" "containerSecurityContext: capabilities.drop=ALL"

  # Empty securityContext block detection (the duplicated-helper bug):
  # `securityContext: {}` or `securityContext:` followed immediately by a non-key line.
  if grep -E "^[[:space:]]*securityContext: \{\}$" -- "$HARD_OUT" >/dev/null 2>&1; then
    mark fail "Empty 'securityContext: {}' block rendered (use the helper, it's render-or-nothing)"
  else
    mark ok "no empty 'securityContext: {}' block"
  fi

  # Detect duplicated `securityContext:` blocks within a single pod spec
  # (the workspace-builder bug: helper + literal toYaml both fire).
  # Count *pod-level* securityContext (indent <= 6 spaces, i.e. directly under spec:)
  # and *container-level* securityContext (indent ~ 10 spaces under containers[].).
  pod_sc_count=$(grep -cE "^[[:space:]]{4,8}securityContext:[[:space:]]*\$" "$HARD_OUT" || true)
  if [[ "$pod_sc_count" -gt 1 ]]; then
    mark fail "Pod-level securityContext rendered $pod_sc_count times (expected ≤ 1) — likely duplicate from helper + raw toYaml"
  else
    mark ok "pod-level securityContext rendered ≤ 1 time ($pod_sc_count)"
  fi

  rm -f "$HARD_OUT"
fi

# === Matrix 3: proxy + proxyCA enabled ====================================
echo ""
echo "============================================================"
echo "Matrix 3: proxy + proxyCA enabled"
echo "============================================================"

if ! is_pod_bearing "$WORKLOAD_KIND"; then
  echo "  (skipping — kind=${WORKLOAD_KIND:-unknown} has no pod spec)"
  mark ok "Matrix 3 skipped — kind=${WORKLOAD_KIND:-unknown}"
  PROXY_OUT=""
else
  render_to_tmp proxy "${HELM_PROXY[@]}" || true
  PROXY_OUT="$RENDERED_PATH"
fi

if [[ -n "$PROXY_OUT" ]]; then
  needs "$PROXY_OUT" "name: HTTP_PROXY" "HTTP_PROXY env emitted"
  needs "$PROXY_OUT" "name: HTTPS_PROXY" "HTTPS_PROXY env emitted"
  needs "$PROXY_OUT" "name: NO_PROXY" "NO_PROXY env emitted"
  needs "$PROXY_OUT" "name: proxy-ca" "proxy-ca volume present"
  needs "$PROXY_OUT" "secretName: corp-ca-bundle" "proxy-ca Secret name wired"

  # Trust-bundle env vars — the platform chart emits 5; runwhen-local should match.
  for var in SSL_CERT_FILE REQUESTS_CA_BUNDLE CURL_CA_BUNDLE NODE_EXTRA_CA_CERTS GIT_SSL_CAINFO; do
    needs "$PROXY_OUT" "name: $var" "$var env emitted under proxyCA"
  done

  rm -f "$PROXY_OUT"
fi

# === Matrix 4: registryOverride ===========================================
echo ""
echo "============================================================"
echo "Matrix 4: registryOverride=artifactory.example.com"
echo "============================================================"
render_to_tmp registry "${HELM_REGISTRY[@]}" || true
REG_OUT="$RENDERED_PATH"

if [[ -n "$REG_OUT" ]]; then
  if grep -E -e "image: \"?artifactory\.example\.com/" -- "$REG_OUT" >/dev/null 2>&1; then
    mark ok "registryOverride applied to container image"
  else
    if grep -E "^[[:space:]]+image:" -- "$REG_OUT" >/dev/null 2>&1; then
      mark fail "registryOverride did NOT rewrite image — template likely hardcodes the registry, or doesn't honour .Values.registryOverride"
    else
      mark ok "no container image in this template — registryOverride check skipped"
    fi
  fi

  rm -f "$REG_OUT"
fi
fi  # end goto_matrix5 == 0 (parent-chart matrices)

# === Matrix 5: subchart overlay propagation ================================
# Verify that operator-supplied opentelemetry-collector.* values flow through
# to the subchart's rendered Deployment. Only runs in --subchart mode.
if [[ -n "$SUBCHART" ]]; then
  echo ""
  echo "============================================================"
  echo "Matrix 5: subchart overlay propagation (${SUBCHART}.*)"
  echo "============================================================"
  render_to_tmp subchart-overlay "${HELM_SUBCHART_OVERLAY[@]}" || true
  SUB_OUT="$RENDERED_PATH"

  if [[ -n "$SUB_OUT" ]]; then
    needs "$SUB_OUT" "cost-center: platform-eng" "${SUBCHART}.additionalLabels reach metadata.labels"
    needs "$SUB_OUT" "policy/enforce: baseline" "${SUBCHART}.podLabels reach pod-template metadata.labels"
    needs_re "$SUB_OUT" "linkerd\\.io/inject: enabled" "${SUBCHART}.podAnnotations reach pod-template metadata.annotations"
    needs "$SUB_OUT" "runAsNonRoot: true" "${SUBCHART}.podSecurityContext.runAsNonRoot honoured"
    needs "$SUB_OUT" "fsGroup: 1000" "${SUBCHART}.podSecurityContext.fsGroup honoured"
    needs "$SUB_OUT" "type: RuntimeDefault" "${SUBCHART}.podSecurityContext.seccompProfile honoured"
    needs_re "$SUB_OUT" "image: \"?artifactory\\.example\\.com/" "${SUBCHART}.image.repository rewritten (subchart has no image.registry knob — full path required)"
    needs "$SUB_OUT" "automountServiceAccountToken: false" "${SUBCHART}.serviceAccount.automountServiceAccountToken opt-out honoured"

    rm -f "$SUB_OUT"
  fi
fi

# === Summary ================================================================
echo ""
echo "============================================================"
if [[ "$FAIL" -eq 0 ]]; then
  printf "\033[32mOK — all enterprise BYO checks passed.\033[0m\n"
  exit 0
else
  printf "\033[31m%d enterprise BYO check(s) failed.\033[0m See output above.\n" "$FAIL"
  echo ""
  echo "Refer to .cursor/skills/new-service-byo/SKILL.md for the full checklist."
  exit 1
fi
