# security-scripts-collection

Real, working security scripts. All take a real EVM address / tx / token
as input and call public RPCs + explorers. They are not linters — each
one runs a real chain query.

## Scripts

| Script | What it does |
|---|---|
| `check-approval.sh`    | Reads `allowance(owner, spender)` for a token via `cast call` |
| `decode-tx.sh`         | Decodes a transaction's calldata + selector via `cast tx` |
| `verify-contract.sh`   | Queries the Etherscan-family explorer API for the source |
| `scan-honeypot.sh`     | **new** Quote buy + sell, flag <50% round-trip as honeypot |
| `analyze-storage.sh`   | **new** Reads slots 0..N, reports non-zero values |
| `check-proxy.sh`       | **new** Detects EIP-1967/EIP-1822 proxy, reports impl + verification |

## Requirements

- [Foundry](https://book.getfoundry.xyz/) (provides `cast`)
- `curl`, `python3`, `bc`

## Usage

```bash
chmod +x scripts/*.sh

# Allowance check
./scripts/check-approval.sh 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 0x1111111254EEB25477B68fb85Ed929f73A960582 ethereum

# Verify a contract
./scripts/verify-contract.sh 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 ethereum

# Decode a tx
./scripts/decode-tx.sh 0xabc...def ethereum

# Honeypot scan
./scripts/scan-honeypot.sh 0x7a250d... 0xToken 1000000000000000000 ethereum

# Storage analysis
./scripts/analyze-storage.sh 0xA0b8... 0 20 ethereum

# Proxy check
./scripts/check-proxy.sh 0xA0b8... ethereum
```

## Chains supported out of the box

- ethereum (Etherscan + Llama RPC)
- base (Basescan + Base RPC)
- arbitrum (Arbiscan + Arbitrum RPC)

## Disclaimer

For educational and security research purposes only.

## License

MIT
