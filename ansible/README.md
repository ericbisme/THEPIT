# THEPIT Ansible

Run playbooks from this directory with `inventory` where a managed-host inventory is required.
Verify live state before applying any playbook.

## Current entry points

- `unifi-syslog-receiver.yml` manages Porter's UDP syslog receiver, exact-source firewall rules,
  APC hostname normalization, and log rotation.
- `apc-nmc-config.yml` renders and validates a non-secret partial AP9631 `config.ini`. Its default
  is render-only; an explicit apply flag backs up the live configuration and uploads the reviewed
  artifact over password-authenticated SCP with a pinned host key.
- `inventory` includes the current UniFi controller as `unifi-controller` in the
  `unifi_controllers` group. Its public Ed25519 host key is pinned; SSH credentials come only from
  `UNIFI_SSH_USERNAME` and `UNIFI_SSH_PASSWORD` in the process environment.
- `unifi-controller-audit.yml` runs the read-only `unifi_controller_audit` role. It verifies the
  controller identity and UniFi services and reports whether a legacy USG `config.gateway.json`
  exists at any known controller path.
- `ups-nut.yml` is existing NUT automation for the directly attached CyberPower UPS on Porter and
  k8s-node1. It does not manage the APC rack UPS.
- `prometheus-node-exporter.yml` is existing workstation exporter automation and depends on the
  external `cloudalchemy.node-exporter` role.

## Quarantined legacy automation

`unifi.yml`, `roles/cloudkey/`, `inventory/host_vars/cloudkey.yml`, and
`inventory/group_vars/cloudkey.yaml` describe the retired UniFi Cloud Key. The current controller is
not a Cloud Key and is not represented by that role. The legacy entry point intentionally fails
instead of provisioning. Keep the encrypted historical variables until they have survived a real
usage cycle and their replacement or archival value has been assessed.

## UniFi controller access

The current controller was verified over read-only SSH as hostname `UCKP`, Debian 11, with Python
3.9 at `/usr/bin/python3`. UniFi Console SSH uses the `root` account and keyboard-interactive
authentication. Load the local secret environment before running Ansible:

```bash
cd ansible
set -a; source ~/codex.env; set +a
ansible -i inventory unifi_controllers -m ansible.builtin.ping
ansible-playbook -i inventory unifi-controller-audit.yml --check
```

If the controller is replaced, reset, or regenerates its SSH keys, stop on the host-key error and
verify the new fingerprint in the local console UI or through an independent trusted path before
updating `files/unifi-controller-known-hosts`. Do not bypass host-key checking.

## APC automation boundary

The AP9631 has SSH/SCP and HTTPS enabled, with Telnet, HTTP, and FTP disabled. Render and review the
partial configuration first. To apply it, export `APC_USERNAME` and `APC_PASSWORD` from the local
secret environment and opt in explicitly:

```bash
cd ansible
ansible-playbook apc-nmc-config.yml
set -a; source ~/codex.env; set +a
ansible-playbook apc-nmc-config.yml -e apc_nmc_apply=true
```

The apply path pins the NMC ECDSA host key, creates a mode-0600 pre-change `config.ini` below
`~/.local/share/thepit/backups/apc/`, uploads over legacy SCP (`scp -O`), waits for SSH and HTTPS,
and verifies Telnet and HTTP are closed. NMC2's SCP server may return status 1 after a complete
transfer, so the playbook also requires the protocol's transfer markers before accepting that
status. A changed NMC or IP requires deliberate host-key verification and a Git update.

Firmware updates, UPS output control, battery service, self-tests, and runtime calibration remain
deliberate maintenance operations because they can interrupt the household network or have weak
rollback.
