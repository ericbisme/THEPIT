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
- `ups-nut-imac-local.yml` is a self-contained local-run playbook for the CyberPower UPS attached
  to the Fedora iMac at `192.168.1.37`. The matching `.service` and `.timer` files provide a daily
  reconciliation after copying this `ansible/` directory to `/opt/thepit-ansible` on that host:

  ```bash
  sudo install -d /opt/thepit-ansible
  sudo cp -a ansible/. /opt/thepit-ansible/
  sudo install -m 0644 /opt/thepit-ansible/ups-nut-imac-local.service /etc/systemd/system/
  sudo install -m 0644 /opt/thepit-ansible/ups-nut-imac-local.timer /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable --now ups-nut-imac-local.timer
  ```
- `imac-k3s-agent.yml` joins the Fedora iMac as an untainted, non-control-plane K3s worker. It
  downloads the pinned K3s binary directly because the Porter mirror is on another VLAN; supply
  `k3s_join_token` only at runtime from the existing server token.
- Porter’s NUT exporter is pinned to the UPS name `cyberpower` in
  `cluster-flux/infrastructure/monitoring/nut-exporter.yaml`. The exporter supports one UPS per
  scrape; when a second UPS is attached, add its `[cyberpower-2]` section to Porter’s `ups.conf`
  and add a second ServiceMonitor endpoint (or ServiceMonitor) with `params.ups: [cyberpower-2]`
  and a matching `ups` relabel. Do not remove the explicit `params.ups` from the existing scrape.
- `prometheus-node-exporter.yml` is existing workstation exporter automation and depends on the
  external `cloudalchemy.node-exporter` role.
- `flatcar-pxe-mirror.yml` configures Porter as a local, signature-verified mirror of Flatcar's
  Stable BIOS PXE kernel and initramfs. It refreshes daily and retains every verified release for
  rollback, but deliberately does not alter UniFi DHCP settings or any existing PXE MAC entry.
  Run it only after reviewing the network and storage implications:

  ```bash
  cd ansible
  ansible-playbook -i inventory flatcar-pxe-mirror.yml
  ```
- `porter-vlan10.yml` reconciles only Porter's local `/etc/hosts` aliases after its VLAN 10 move.
  It does not manage Pi-hole DNS, UniFi DHCP, or switch-port profiles.
- `flatcar/node1-canary.bu` is a non-deployed, non-destructive Flatcar Butane source for the
  node1 PXE canary. `make -C flatcar node1-canary` produces ignored Ignition JSON under
  `build/flatcar/`. `flatcar-node1-canary.yml` can explicitly stage that artifact and an opt-in
  PXELINUX menu; its timeout continues to boot node1's local disk. Neither playbook changes
  UniFi DHCP, node disks, NFS, or K3s.
- `flatcar/node1-diagnostic.bu` is the first response to a failed storage canary: a separate,
  opt-in Flatcar PXE profile with the same operator SSH key but **no** LVM activation, mounts,
  NFS, or Kubernetes. Stage it only with the explicit diagnostic state:

  ```bash
  make -C flatcar node1-diagnostic
  ansible-playbook -i inventory/hosts flatcar-node1-canary.yml \
    -e flatcar_node1_canary_state=diagnostic
  ```

  The PXELINUX timeout still boots the local disk. Select `Boot Flatcar minimal diagnostic
  (no storage)` at the physical console; it adds high-detail systemd console logging so that a
  subsequent clean reboot can be attributed before any storage configuration is reintroduced.
- `flatcar/node1-upstream-minimal-pxelinux.cfg` is the next isolation boundary if the diagnostic
  profile also reboots: it uses only the Flatcar PXE kernel and initramfs, plus VGA autologin on
  `tty1`. It has no Ignition URL, DHCP/network arguments, custom logging, storage activation, or
  SSH configuration. Stage it with:

  ```bash
  ansible-playbook -i inventory/hosts flatcar-node1-canary.yml \
    -e flatcar_node1_canary_state=upstream-minimal
  ```

  Select `Boot Flatcar upstream minimal (no Ignition or storage)` at Node1's console. Its timeout
  still boots the local disk; do not add the watchdog test until this baseline result is recorded.
- `flatcar/node1-network-ssh-pxelinux.cfg` reintroduces only `ip=dhcp`, `rd.neednet=1`, and
  Flatcar's documented `sshkey` kernel option after the upstream-minimal boot is accepted. It is
  still Ignition-free and storage-free. Stage it with:

  ```bash
  ansible-playbook -i inventory/hosts flatcar-node1-canary.yml \
    -e flatcar_node1_canary_state=network-ssh
  ```

  After selecting `Boot Flatcar network + SSH (no Ignition or storage)`, verify the ephemeral
  boot with `ssh -i ~/.ssh/ericbismenet core@192.168.10.126`. Do not use it to modify disks.
- `flatcar/node1-ignition-ssh.bu` compiles to an otherwise empty Ignition document. The paired
  PXE menu preserves the accepted DHCP+SSH arguments and adds only `flatcar.first_boot=1` and
  its HTTP URL. This identifies whether Ignition fetch/processing—not its previous storage
  configuration—caused the reboot. Build and stage it with:

  ```bash
  make -C flatcar node1-ignition-ssh
  ansible-playbook -i inventory/hosts flatcar-node1-canary.yml \
    -e flatcar_node1_canary_state=ignition-ssh
  ```
- `flatcar/node1-prestorage-pxelinux.cfg` intentionally bundles the accepted network/SSH path
  with the original diagnostic logging flags and non-storage Ignition document. It is an explicit
  operator-approved shortcut across the individual logging/unit/metadata checks; it remains safe
  for existing data because it has no LVM, mount, NFS, K3s, or disk directives. Stage it with
  `-e flatcar_node1_canary_state=prestorage`.
- `flatcar/node1-readonly-mounts-pxelinux.cfg` is the first storage profile after the pre-storage
  test. Its Ignition source mounts only `/dev/bulk_storage/bulk_storage` and
  `/dev/k8s_storage/k8s_storage` as XFS with `ro,nosuid,nodev,noexec`. Flatcar auto-activates
  the legacy LVM groups, so the source deliberately contains no `vgchange` unit. Stage it with
  `-e flatcar_node1_canary_state=readonly-mounts`.
- `flatcar/node1-nfs-readonly-pxelinux.cfg` is the staged NFS-only canary. It keeps both XFS
  volumes mounted read-only and starts only `nfs-server.service`. Its exports are read-only and
  root-squashed for Porter (`192.168.10.125`), node1/node2 (`192.168.10.126` and
  `192.168.10.127`), and the trusted laptop LAN (`192.168.1.0/24`). It does not enable K3s.
  Build with `make -C flatcar node1-nfs-readonly`; stage only after explicit approval using
  `-e flatcar_node1_canary_state=nfs-readonly`.

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
