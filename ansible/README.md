# THEPIT Ansible

Run playbooks from this directory with `inventory` where a managed-host inventory is required.
Verify live state before applying any playbook.

## Current entry points

- `unifi-syslog-receiver.yml` manages Porter's UDP syslog receiver, exact-source firewall rules,
  APC hostname normalization, and log rotation.
- `apc-nmc-config.yml` renders and validates a non-secret partial AP9631 `config.ini`. It does not
  contact or change the NMC.
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

## APC automation boundary

The AP9631 supports applying `config.ini` through its web interface or SCP. Automated upload is
deferred until SSH/SCP is enabled and tested. Firmware updates, UPS output control, battery service,
self-tests, and runtime calibration remain deliberate maintenance operations because they can
interrupt the household network or have weak rollback.
