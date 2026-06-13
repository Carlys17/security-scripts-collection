#!/bin/bash
# Quick storage-layout analysis: read slots 0..N and report non-zero values
# with an optional 4byte selector lookup for known ABIs (ERC-20, ERC-721, Proxy).
set -euo pipefail

ADDR="${1:?Usage: $0 <address> [start_slot=0] [count=20] [chain=ethereum]}"
SLOT="${2:-0}"
COUNT="${3:-20}"
CHAIN="${4:-ethereum}"

case "$CHAIN" in
    ethereum) RPC="https://eth.llamarpc.com" ;;
    base)     RPC="https://mainnet.base.org" ;;
    arbitrum) RPC="https://arb1.arbitrum.io/rpc" ;;
    *) echo "Unsupported chain: $CHAIN"; exit 1 ;;
esac

echo "address  : $ADDR"
echo "start    : $SLOT"
echo "count    : $COUNT"
echo "chain    : $CHAIN"
echo ""

for ((i=0; i<COUNT; i++)); do
    cur=$((SLOT + i))
    HEX=$(printf "0x%064x" "$cur")
    VAL=$(cast storage "$ADDR" "$HEX" --rpc-url "$RPC" 2>/dev/null || echo "0x0")
    if [[ "$VAL" != "0x0000000000000000000000000000000000000000000000000000000000000000" ]]; then
        # Try to interpret as a uint256 / address
        ADDR_DECODE=$(cast abi-decode "decodeUintToAddress(uint256)(address)" "$VAL" 2>/dev/null || true)
        printf "slot %3d (%s): %s\n" "$cur" "$HEX" "$VAL"
    fi
done
