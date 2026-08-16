# Calibre-Web

Calibre-Web exposes the protected legacy Calibre library at the private name
`books.ericbisme.net`. It is deliberately not internet-facing.

| Item | Value |
| --- | --- |
| VIP | `192.168.10.128` |
| DNS | Pi-hole local A record managed by ExternalDNS |
| Library | `/mnt/bulk_storage/mediaserver/books` on node1, exported and mounted read-only |
| Config | 2 GiB dynamic NFS PVC (`calibre-web-config`) |
| Image | LinuxServer Calibre-Web `0.6.26-ls392`, pinned by digest |

The workload is pinned to `k8s-node1` because that is the only current NFS
client authorized to mount the books export. Add a deliberate NFS export and
update the node selector before scheduling it anywhere else.

## First login

Visit `http://books.ericbisme.net`, complete the upstream first-run setup, and
set a strong administrator password immediately. The first run creates only
application configuration on the config PVC. It cannot modify the book library.

## Verify

```sh
dig +short @192.168.1.3 books.ericbisme.net A
kubectl -n thepit get deploy,pod,svc,pvc
kubectl -n metallb-system exec daemonset/metallb-frr-k8s -c frr -- \
  vtysh -c 'show bgp ipv4 unicast summary'
```
