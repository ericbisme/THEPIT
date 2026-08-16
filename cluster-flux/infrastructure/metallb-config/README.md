# THEPIT MetalLB BGP

MetalLB provides the private `LoadBalancer` address plane for the THEPIT
cluster. Its FRR speaker peers directly with the USG on VLAN 10:

| Component | Value |
| --- | --- |
| MetalLB ASN | `64500` |
| USG ASN | `64501` |
| Peer | `192.168.10.1` |
| Speaker source | `192.168.10.126` (`k8s-node1`) |
| Reserved service pool | `192.168.10.128`–`192.168.10.131` |

The pool is announced by both BGP and layer 2. BGP serves routed clients on
other VLANs; layer 2 answers ARP for clients that share VLAN 10 with the VIP.
Without the latter, same-subnet clients would ARP for the address instead of
consulting the USG's BGP route.

The pool has `autoAssign: false`. A service receives an address only when its
manifest explicitly requests one from `thepit-services`; this prevents an
accidental `LoadBalancer` service from claiming a household address.

The USG BGP override is maintained separately in
`ansible/roles/unifi_usg_bgp/`. Its `config.gateway.json` must remain present
on the controller and be provisioned before the peer can establish.

## Verify

```sh
flux get kustomizations -A
kubectl -n metallb-system get ipaddresspool,bgppeer,bgpadvertisement
kubectl -n metallb-system exec daemonset/metallb-frr-k8s -c frr -- \
  vtysh -c 'show bgp ipv4 unicast summary'
kubectl get svc -A --field-selector spec.type=LoadBalancer
```

An established peer shows the USG with a duration in `Up/Down`, not an FSM
state such as `Active` or `Connect`. Before any LoadBalancer service exists,
both prefix counters should be zero. A service claiming an address results in
a host (`/32`) route advertisement, never the whole pool.

## First service pattern

For a service such as Calibre, reserve a specific address in Git and opt in to
the pool rather than relying on allocator order:

```yaml
metadata:
  annotations:
    metallb.io/address-pool: thepit-services
spec:
  type: LoadBalancer
  loadBalancerIP: 192.168.10.128
```

Use a matching, explicitly annotated Ingress for the private DNS name. The
ExternalDNS controller is `upsert-only` and only observes opted-in Ingresses;
see `../external-dns/README.md`.
