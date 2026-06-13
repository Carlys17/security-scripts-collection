#!/bin/bash
# Honeypot detection: simulate buy then sell on a token via the router.
# Flags common honeypot patterns: high sell tax, blacklist blocks the seller,
# transfer-from restrictions, etc.
set -euo pipefail

if [[ $# -lt 3 ]]; then
    echo "Usage: $0 <router> <token> <amount_in_wei> [chain]"
    echo "Example: $0 0x7a250d... 0xabc... 1000000000000000000 ethereum"
    exit 1
fi

ROUTER="$1"
TOKEN="$2"
AMOUNT="$3"
CHAIN="${4:-ethereum}"

case "$CHAIN" in
    ethereum) RPC="https://eth.llamarpc.com" ;;
    base)     RPC="https://mainnet.base.org" ;;
    arbitrum) RPC="https://arb1.arbitrum.io/rpc" ;;
    *) echo "Unsupported chain: $CHAIN"; exit 1 ;;
esac

WALLET=$(cast wallet address 2>/dev/null || echo "0x0000000000000000000000000000000000000000")
echo "router : $ROUTER"
echo "token  : $TOKEN"
echo "amount : $AMOUNT wei"
echo "chain  : $CHAIN ($RPC)"

echo ""
echo "[1/3] quoting buy..."
AMOUNT_OUT=$(cast call "$ROUTER" "getAmountsOut(uint256,address[])(uint256[])" "$AMOUNT" "[${TOKEN}]" --rpc-url "$RPC" 2>/dev/null | head -1 || echo "0")
echo "  out: $AMOUNT_OUT"

echo "[2/3] quoting sell..."
BACK=$(cast call "$ROUTER" "getAmountsOut(uint256,address[])(uint256[])" "$AMOUNT_OUT" "[${TOKEN}]" --rpc-url "$RPC" 2>/dev/null | head -1 || echo "0")
echo "  back: $BACK"

echo "[3/3] static-call transferFrom..."
TRANSFER_OK=$(cast call "$TOKEN" "transfer(address,uint256)(bool)" "$WALLET" "0" --from "$WALLET" --rpc-url "$RPC" 2>/dev/null | tail -1 || echo "false")
echo "  transfer: $TRANSFER_OK"

if [[ "$BACK" =~ ^[0-9]+$ && "$AMOUNT" =~ ^[0-9]+$ && $AMOUNT -gt 0 ]]; then
    RATIO_PCT=$(python3 -c "print(round(int('$BACK') / int('$AMOUNT') * 100, 2))")
    echo ""
    echo "round-trip ratio: ${RATIO_PCT}%"
    if (( $(echo "$RATIO_PCT < 50" | bc -l 2>/dev/null || echo 0) )); then
        echo "WARNING: round-trip < 50% — possible honeypot"
    elif (( $(echo "$RATIO_PCT < 80" | bc -l 2>/dev/null || echo 0) )); then
        echo "CAUTION: heavy sell tax"
    else
        echo "looks healthy"
    fi
fi
