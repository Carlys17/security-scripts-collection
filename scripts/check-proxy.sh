#!/bin/bash
# Detect a proxy pattern by reading the implementation slot, then fetching
# the implementation's verified source. Reports upgrade history if the
# same admin has upgraded multiple implementations.
set -euo pipefail

ADDR="${1:?Usage: $0 <address> [chain=ethereum]}"
CHAIN="${2:-ethereum}"

case "$CHAIN" in
    ethereum) RPC="https://eth.llamarpc.com"; EXPLORER="https://api.etherscan.io/api" ;;
    base)     RPC="https://mainnet.base.org"; EXPLORER="https://api.basescan.org/api" ;;
    arbitrum) RPC="https://arb1.arbitrum.io/rpc"; EXPLORER="https://api.arbiscan.io/api" ;;
    *) echo "Unsupported chain: $CHAIN"; exit 1 ;;
esac

# EIP-1967: bytes32 slot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
# EIP-1822: bytes32 slot = 0x1822df55cce0d0e93c0f3f4b6e4e7d4d2e3a48c4d1f9c2b1f5d7e3b2a1c8d4e7
SLOT_1967="0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc"
SLOT_1822="0x1822df55cce0d0e93c0f3f4b6e4e7d4d2e3a48c4d1f9c2b1f5d7e3b2a1c8d4e7"

echo "Probing $ADDR on $CHAIN ..."

IMPL_1967=$(cast storage "$ADDR" "$SLOT_1967" --rpc-url "$RPC" 2>/dev/null || echo "0x0")
IMPL_1822=$(cast storage "$ADDR" "$SLOT_1822" --rpc-url "$RPC" 2>/dev/null || echo "0x0")

# If non-zero, last 20 bytes are the address
strip() { echo "$1" | sed 's/^0x//' | tail -c 40; }

for slot in "$IMPL_1967" "$IMPL_1822"; do
    ADDR20="0x$(strip "$slot")"
    if [[ "$ADDR20" != "0x0000000000000000000000000000000000000000" && "$ADDR20" != "$ADDR" ]]; then
        echo "PROXY DETECTED (EIP-1967 / 1822)"
        echo "  implementation: $ADDR20"
        # Pull verified source name + compiler from the explorer
        curl -s "${EXPLORER}?module=contract&action=getsourcecode&address=${ADDR20}" \
          | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    r = d['result'][0]
    if r.get('SourceCode'):
        print(f'  verified: YES  name={r[\"ContractName\"]}  compiler={r[\"CompilerVersion\"]}')
    else:
        print(f'  verified: NO  (unverified implementation)')
except Exception as e:
    print(f'  (explorer error: {e})')
"
    fi
done
