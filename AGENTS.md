# THEPIT homelab repository

This repository is the source of truth for documentation and infrastructure-as-code for the
THEPIT site, network, and house. Apply the Homelab SRE guidance in `../AGENTS.md` to all work here.

## Repository boundaries

- `docs/` is the THEPIT wiki and a Git submodule with its own history. Run Git commands for it
  with `git -C docs`; commit wiki changes there before updating the parent submodule pointer.
- `diagrams/` contains Graphviz source. Treat rendered images as derived artifacts and update them
  with `diagrams/publish.sh` only after reviewing the source diff.
- `ansible/` contains host and UniFi automation migrated into this repository on 2026-08-14. It is
  currently uncommitted and must be reviewed and reconciled with live state before deployment.
- Preserve existing modified and untracked files. In particular, `diagrams/rack.dot` and current
  wiki work predate repository initialization.

## Operational truth and safety

- Git describes desired or historical state; verify the live controller, devices, host services,
  listeners, firewall, logs, and backups before acting.
- THEPIT networking is household-critical. Before changing the controller, USG, switching, Wi-Fi,
  DNS, DHCP, VLANs, or the syslog receiver, state what changes, what could break, how failure will
  be detected, how to roll back, and who is home to notice.
- Keep controller and device configuration in Git-backed automation where the platform supports
  it. Use SSH for read-only diagnostics and break-glass recovery, not routine configuration.
- Never print or commit API keys, passwords, PSKs, tokens, certificates, private keys, decrypted
  Ansible Vault content, or raw API responses that may contain them. Query narrow endpoints and
  filter responses before displaying or saving them.
- `~/codex.env` contains local UniFi API connection values. It must remain outside Git with mode
  `0600`. The controller currently enforces HTTPS without a trusted certificate; do not send the
  API key over plaintext HTTP.
- `ansible/inventory/group_vars/cloudkey.yaml` is Ansible Vault ciphertext. Keep it encrypted in
  Git; never display or commit its decrypted form or a vault-password file.
- Quarantine before deletion, snapshot or back up before provisioning, and keep a direct recovery
  path to the USG at `192.168.1.1` when changing the network edge.

## Current verified baseline

The evidence ledger is `docs/UNIFI-INVENTORY.md`. As of 2026-08-14, the local controller is at
`192.168.2.2`, UniFi Network is `10.5.67`, and site `THEPIT` reports nine managed devices online.
The syslog receiver on Porter (`192.168.1.54`) is active on TCP/UDP 514, but no UniFi device logs
have been observed. Re-verify these facts at the start of later operational work.

## Change workflow

1. Inspect both parent and wiki-submodule status.
2. Record measured facts, assumptions, and the intended service target.
3. Make the smallest reviewable Git change; keep secrets external.
4. Run syntax, check-mode, and diff validation before deployment.
5. State blast radius and rollback before touching running state.
6. Apply one change at a time and verify user-facing behavior plus device/controller health.
7. Update the evidence ledger and runbook with the observed result, including failures.
