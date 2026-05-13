#!/bin/bash
# Decode transaction input data
TXHASH="${1:?Usage: decode-tx.sh <tx_hash> [chain]}"
CHAIN="${2:-ethereum}"
case "$CHAIN" in
    ethereum) RPC="https://eth.llamarpc.com" ;;
    base) RPC="https://mainnet.base.org" ;;
    arbitrum) RPC="https://arb1.arbitrum.io/rpc" ;;
    *) echo "Unsupported chain"; exit 1 ;;
esac
echo "Decoding: $TXHASH on $CHAIN"
cast tx "$TXHASH" --rpc-url "$RPC" 2>/dev/null | head -20
echo "Selector: $(cast tx "$TXHASH" input --rpc-url "$RPC" 2>/dev/null | head -c 10)"
