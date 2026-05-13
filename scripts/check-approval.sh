#!/bin/bash
# Check token approvals for suspicious allowances
TOKEN="${1:?Usage: check-approval.sh <token> <spender> [chain]}"
SPENDER="${2:?Usage: check-approval.sh <token> <spender> [chain]}"
CHAIN="${3:-ethereum}"
case "$CHAIN" in
    ethereum) RPC="https://eth.llamarpc.com" ;;
    base) RPC="https://mainnet.base.org" ;;
    arbitrum) RPC="https://arb1.arbitrum.io/rpc" ;;
    *) echo "Unsupported chain"; exit 1 ;;
esac
echo "Checking approvals: $TOKEN -> $SPENDER on $CHAIN"
ALLOWANCE=$(cast call "$TOKEN" "allowance(address,address)(uint256)" "$(cast wallet address)" "$SPENDER" --rpc-url "$RPC" 2>/dev/null)
echo "Allowance: $ALLOWANCE"
