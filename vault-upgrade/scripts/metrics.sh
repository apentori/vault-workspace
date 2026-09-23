#!/usr/bin/env bash
# Query Vault telemetry metrics (/v1/sys/metrics?format=prometheus) for quick
# checks outside of Grafana.
#
# Usage:
#   ./scripts/metrics.sh              # filtered summary for all nodes
#   ./scripts/metrics.sh 8300         # filtered summary for one node
#   ./scripts/metrics.sh --full       # full metrics dump for all nodes
#   ./scripts/metrics.sh --full 8400  # full metrics dump for one node

DEFAULT_PORTS=(8200 8300 8400)
FULL=0
PORTS=()

for arg in "$@"; do
  case "${arg}" in
    -f|--full) FULL=1 ;;
    [0-9]*) PORTS+=("${arg}") ;;
    *) echo "Unknown argument: ${arg}" >&2; exit 1 ;;
  esac
done

if [ ${#PORTS[@]} -eq 0 ]; then
  PORTS=("${DEFAULT_PORTS[@]}")
fi

# Key metrics to follow an upgrade: seal/active state, version rollout,
# raft/autopilot health and request traffic.
METRIC_FILTER='^(vault_core_unsealed|vault_core_active|vault_core_standby|vault_version_info|vault_raft_leader_changes_total|vault_raft_num_peers|vault_raft_apply_total|vault_raft_autopilot_|vault_http_requests_total|vault_http_request_duration_seconds_count)'

fetch_metrics() {
  local port=$1
  curl -sf --max-time 5 "http://localhost:${port}/v1/sys/metrics?format=prometheus"
}

for port in "${PORTS[@]}"; do
  echo "==> Metrics for node on port ${port}"
  METRICS="$(fetch_metrics "${port}")"
  if [ -z "${METRICS}" ]; then
    echo "    Node unreachable (is it running and unsealed?)"
    echo ""
    continue
  fi
  if [ "${FULL}" -eq 1 ]; then
    echo "${METRICS}"
  else
    echo "${METRICS}" | grep -E "${METRIC_FILTER}" | grep -v '^#'
  fi
  echo ""
done
