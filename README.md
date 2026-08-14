# THEPIT

THEPIT is the infrastructure and operations repository for this house and homelab. It is the
canonical home for network documentation, diagrams, runbooks, and infrastructure-as-code.

## Start here

- [`AGENTS.md`](AGENTS.md) — operating and safety rules for automated work
- [`docs/Home.md`](docs/Home.md) — wiki home
- [`docs/UNIFI-INVENTORY.md`](docs/UNIFI-INVENTORY.md) — evidence-backed UniFi inventory
- [`docs/USG-REPLACEMENT-INVENTORY.md`](docs/USG-REPLACEMENT-INVENTORY.md) — measured gateway,
  Xfinity, modem, and migration requirements
- [`ansible/`](ansible/) — host, UPS-monitoring, APC NMC, and syslog automation
- [`diagrams/network.dot`](diagrams/network.dot) — historical network topology source
- [`diagrams/dns.dot`](diagrams/dns.dot) — historical DNS-flow source

`docs/` is a Git submodule with its own commit history. Infrastructure changes belong in the
parent repository; wiki documentation is committed in the submodule and then its parent pointer
is updated.

## Current state

The Ansible tree was migrated into this repository on 2026-08-14 and reconciled with the live
Porter syslog receiver. The receiver permits UDP 514 only from the controller and explicitly listed
infrastructure addresses; the earlier broad subnet rule and TCP listener were removed.

APC Network Management Card settings are represented as a reviewable partial `config.ini` rendered
by [`ansible/apc-nmc-config.yml`](ansible/apc-nmc-config.yml). Rendering is non-mutating. Uploading
the file remains a deliberate maintenance step until secure SSH/SCP access and post-change checks
are established.
