# Security Scripts Collection

Collection of security tools and scripts for blockchain auditing, VPS hardening, and smart contract analysis.

## Scripts

### Blockchain Security
- `check-approval.sh` — Check token approvals for suspicious allowances
- `verify-contract.sh` — Verify contract source code vs bytecode
- `scan-honeypot.sh` — Quick honeypot detection via buy/sell simulation

### VPS Hardening
- `harden-ssh.sh` — SSH security hardening (key-only, disable root)
- `audit-ports.sh` — Port scanning and service audit
- `check-cve.sh` — CVE vulnerability checker

### Smart Contract Analysis
- `analyze-storage.sh` — Storage layout analysis
- `check-proxy.sh` — Proxy pattern detection and implementation check
- `decode-tx.sh` — Transaction input data decoder

## Usage
```bash
chmod +x scripts/*.sh
./scripts/check-approval.sh 0xTokenAddress 0xSpenderAddress
./scripts/verify-contract.sh 0xContractAddress ethereum
```

## Disclaimer
For educational and security research purposes only.
