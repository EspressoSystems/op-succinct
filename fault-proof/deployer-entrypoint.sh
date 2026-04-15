#!/bin/bash
set -euo pipefail

# FDG Deployer entrypoint script.
#
# Runs the full OPSuccinctFaultDisputeGame deployment pipeline:
#   1. fetch-fault-dispute-game-config  — computes vkeys, rollup config hash,
#      and assembles the JSON config read by the Forge deployment script.
#   2. forge script DeployOPSuccinctFDG.s.sol — deploys contracts and
#      (optionally) wires them into the DisputeGameFactory.
#
# All configuration is passed via environment variables. Required:
#   L1_RPC, L2_RPC, L2_NODE_RPC  — RPC endpoints
#   PRIVATE_KEY                    — deployer private key (for forge broadcast)
#
# See fetch-fault-dispute-game-config and DeployOPSuccinctFDG.s.sol for the
# full list of supported env vars.

# --- Validate required env vars ---------------------------------------------
missing=""
for var in L1_RPC L2_RPC L2_NODE_RPC PRIVATE_KEY; do
    if [ -z "${!var:-}" ]; then
        missing="${missing} ${var}"
    fi
done
if [ -n "${missing}" ]; then
    echo "ERROR: Missing required environment variables:${missing}"
    exit 1
fi

CONFIG_PATH="${OP_SUCCINCT_FAULT_DISPUTE_GAME_CONFIG_PATH:-/app/contracts/opsuccinctfdgconfig.json}"
export OP_SUCCINCT_FAULT_DISPUTE_GAME_CONFIG_PATH="${CONFIG_PATH}"

# --- Stage 1: Generate config JSON (vkeys, rollup config hash, etc.) --------
echo "=== Stage 1: Fetching FDG configuration ==="

# The binary tries to load a dotenv file; create an empty one so it doesn't
# warn when running in a container where all config comes from env vars.
touch /app/.env

fetch-fault-dispute-game-config --env-file /app/.env

if [ ! -f "${CONFIG_PATH}" ]; then
    echo "ERROR: Config file was not created at ${CONFIG_PATH}"
    exit 1
fi

echo "Config written to ${CONFIG_PATH}"

# --- Stage 2: Deploy contracts via Forge ------------------------------------
echo "=== Stage 2: Deploying FDG contracts ==="

# Use L1_RPC as the default RPC URL; allow RPC_URL override.
RPC_URL="${RPC_URL:-${L1_RPC}}"

cd /app/contracts

forge script script/fp/DeployOPSuccinctFDG.s.sol:DeployOPSuccinctFDG \
    --broadcast \
    --no-storage-caching \
    --slow \
    --rpc-url "${RPC_URL}" \
    --private-key "${PRIVATE_KEY}"

echo "=== FDG deployment complete ==="
