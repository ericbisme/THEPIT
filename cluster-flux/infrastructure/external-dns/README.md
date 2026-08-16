# ExternalDNS private-zone bootstrap

`external-dns` is deliberately restricted to annotated `Ingress` objects in
`ericbisme.net` and uses Pi-hole's local DNS API. It never manages the public
authoritative zone.

The Pi-hole password is not stored in Git. Before Flux installs the release,
create the required namespace-local secret from the operator environment:

```sh
kubectl -n external-dns create secret generic pihole-credentials \
  --from-literal=password="$PI_HOLE_PASSWORD"
```

An Ingress must opt in explicitly:

```yaml
metadata:
  annotations:
    external-dns.alpha.kubernetes.io/controller: thepit-private
```

ExternalDNS is configured `upsert-only` with the `noop` registry so it cannot
delete manually managed household records.
