# UniFi syslog receiver on Porter

## Deployment status

Deployed and locally validated on 2026-08-14. Rsyslog is active and listening only on UDP 514.
Firewalld permits the explicitly declared infrastructure addresses in `unifi_syslog_sources`; the earlier broad
`192.168.1.0/24` UDP rule and TCP rule/listener were removed. A local test message was written to
`/var/log/remote/unifi/porter.ericbisme.net.log`.

The controller destination was enabled manually through **Control Plane > Integrations > System
Logging / SIEM** on 2026-08-14. A controller test event reached Porter from `192.168.2.2` and was
stored as CEF in `unifi.log`, proving the UniFi OS export path.

In the Network application, **Settings > CyberSecure > Traffic Logging > Activity Logging
(Syslog)** was configured for the SIEM destination with gateway, access point, switch, and other
event categories. Network events arrive through the controller and are stored in `UCKP.log` as
CEF. The legacy setting reports enabled with all relevant contents selected; its destination is
inherited from the console-wide SIEM configuration.

A Back Yard AP canary proved the collection chain. After automatic provisioning, the AP sent
encrypted device logging to the controller on UDP 5514. Arbitrary messages injected with `logger`
were not exported, but normal Network events derived from managed devices were. Do not use
injected raw messages as the coverage test for this version.

Initial device evidence in `UCKP.log`:

| Device | Observed | Evidence |
|---|---|---|
| `sw-e-1-living` | yes | Wired client connected/disconnected |
| `Back Yard` | yes | Wi-Fi client disconnected |
| `Front Yard` | yes | Wi-Fi client disconnected |
| `Basement` | yes | Wi-Fi client connected |
| `USG-Pro-4` | not yet | No event in initial window |
| `sw-c-0-rack` | not yet | No event in initial window |
| `sw-e-0-living` | not yet | No event in initial window |
| `sw-e-1-office` | not yet | No event in initial window |
| `Laundry Room, Center` | not yet | No event in initial window |

All nine remained online. Confirm the remaining five through normal events over a real usage cycle;
do not restart or reprovision household network devices solely to manufacture evidence.

Debug logging was enabled temporarily during validation. It records sensitive client identity,
address, roaming, and usage details. Disable debug after the coverage observation period and
measure `UCKP.log` growth before choosing final retention.

A pre-change Network backup is stored outside Git at
`~/.local/share/thepit/backups/unifi/2026-08-14-pre-syslog-10.5.67.unf` with mode `0600` and SHA-256
`5534dce99003ba9f682dabe6884b7deb8237577c292a8312063075c3337a180d`.

`porter.ericbisme.net` receives UDP syslog on port 514 from the controller and nine explicitly
listed UniFi device addresses in `unifi-syslog-receiver.yml`. Messages are separated by sender
hostname under
`/var/log/remote/unifi/` and retained for 30 daily rotations, with an additional
100 MiB per-file rotation threshold.

The APC AP9631 management card at `192.168.1.93` is also an explicit source. Its messages are kept
separately under `/var/log/remote/apc/` with the same rotation policy. The UPS configuration itself
is managed through its legacy web interface and must be reconciled here after changes.

APC syslog was configured on 2026-08-14 for `192.168.1.54:514/udp`; global syslog was already
enabled with the default `user` facility and Critical/Warning/Info severity mappings. The card's
built-in informational test proved the sender, firewall, listener, routing, and storage path.

The card's system name and DNS hostname are both `apcF8EE73`, matching UniFi. Its legacy firmware
does not send that value in a conventional RFC 3164 hostname field, causing rsyslog to parse `MOY`
as the hostname. Porter therefore normalizes messages from the exact `192.168.1.93` source to
hostname `apcF8EE73` and file `/var/log/remote/apc/apcF8EE73.log`. The original `MOY.log` is retained
as pre-normalization incident evidence.

The AP9631 was upgraded from AOS/SUMX 6.2.1 to 7.2.2 on 2026-08-14. Syslog configuration survived
the management-interface reboots and a post-upgrade test reached `apcF8EE73.log`. FTP was used for
the supported staged transfer and then disabled through the CLI; TCP/21 was verified closed.

A pre-change AP9631 configuration export is stored outside Git at
`~/.local/share/thepit/backups/apc/2026-08-14-pre-syslog-config.ini` with mode `0600` and SHA-256
`8c11594a0a892ab8a732ad9ae8f622a26122ec53373d0c5544792834f205707d`. The export may contain
sensitive configuration and must not be committed.

Deploy from this directory with:

```bash
ansible-playbook -i inventory unifi-syslog-receiver.yml --limit porter
```

Validate locally without changing UniFi:

```bash
logger --udp --server 127.0.0.1 --port 514 "unifi syslog receiver test"
sudo find /var/log/remote/unifi -maxdepth 1 -type f -ls
sudo grep -R -F "unifi syslog receiver test" /var/log/remote/unifi
```

Porter's management/syslog path is the onboard Intel `eno1` interface at
`192.168.1.54`. NetworkManager lease history showed the same address on every
recorded renewal from 2026-06-21 through 2026-07-31. The previous receiver setup gave `eno1` route
metric 50 and disabled automatic connection of the redundant USB ASIX adapter
(`Wired connection 1`). Those network mutations are deliberately not part of the syslog
playbook; the USB adapter remains a recoverable fallback.

The stable address remains DHCP-managed. Verify that UniFi shows a fixed-IP
reservation for MAC `00:1f:c6:9b:98:36`; repeated leases are strong evidence but
not proof of controller configuration.

Emergency network rollback:

```bash
sudo nmcli connection up "Wired connection 1"
```

The intended controller device-syslog destination is `192.168.1.54:514/udp`. Controller CEF export under
**Integration > System Logging / SIEM** is separate work; start with system, security, internet,
and power events and avoid high-volume client activity until measured.

Rollback:

```bash
sudo systemctl disable --now rsyslog
for source in 192.168.2.2 192.168.1.1 192.168.1.53 192.168.1.88 192.168.1.89 192.168.1.93 192.168.1.94 \
  192.168.1.128 192.168.1.129 192.168.1.130 192.168.10.41; do
  sudo firewall-cmd --permanent --zone=FedoraWorkstation \
    --remove-rich-rule="rule family=ipv4 source address=${source}/32 port port=514 protocol=udp accept"
done
sudo firewall-cmd --reload
```

Quarantine configuration files before deleting them. Retained logs may contain
client names, IPs, MAC addresses, admin activity, and security events; protect
them as sensitive operational data.
