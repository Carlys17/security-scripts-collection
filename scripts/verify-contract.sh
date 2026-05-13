#!/bin/bash
# Quick contract verification check
ADDRESS="${1:?Usage: verify-contract.sh <address> [chain]}"
CHAIN="${2:-ethereum}"
case "$CHAIN" in
    ethereum) EXPLORER="https://api.etherscan.io/api" ;;
    base) EXPLORER="https://api.basescan.org/api" ;;
    arbitrum) EXPLORER="https://api.arbiscan.io/api" ;;
    *) echo "Unsupported chain"; exit 1 ;;
esac
echo "Checking verification: $ADDRESS on $CHAIN"
RESULT=$(curl -s "${EXPLORER}?module=contract&action=getsourcecode&address=${ADDRESS}")
echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); r=d['result'][0]; print(f'Verified: {\"YES\" if r[\"SourceCode\"] else \"NO\"} | Name: {r[\"ContractName\"]} | Compiler: {r[\"CompilerVersion\"]}')" 2>/dev/null
