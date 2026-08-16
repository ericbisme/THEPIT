# ExternalDNS private-zone bootstrap

`external-dns` is deliberately restricted to annotated `Ingress` objects and
`LoadBalancer` Services in `ericbisme.net`, and uses Pi-hole's local DNS API.
It never manages the public authoritative zone.

The Pi-hole password is not stored in Git. Before Flux installs the release,
create the required namespace-local secret from the operator environment:

```sh
kubectl -n external-dns create secret generic pihole-credentials \
  --from-literal=password="$PI_HOLE_PASSWORD"
```

An Ingress or LoadBalancer Service must opt in explicitly. The controller uses
the upstream `dns-controller` annotation value and also filters on that exact
annotation, so an unannotated resource is never eligible:

```yaml
metadata:
  annotations:
    external-dns.alpha.kubernetes.io/controller: dns-controller
```

A LoadBalancer Service should also set the explicit private target assigned by
MetalLB, for example:

```yaml
metadata:
  annotations:
    external-dns.alpha.kubernetes.io/hostname: books.ericbisme.net
    external-dns.alpha.kubernetes.io/target: 192.168.10.128
```

ExternalDNS is configured `upsert-only` with the `noop` registry so it cannot
delete manually managed household records.
