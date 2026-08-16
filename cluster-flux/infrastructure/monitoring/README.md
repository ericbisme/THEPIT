# Monitoring

This component deploys the pinned `kube-prometheus-stack` chart into the
`observability` namespace.

## Current scope

- Prometheus stores seven days (up to 8 GB) of metrics on `thepit-nfs`.
- Grafana stores dashboards and settings on a 2 GiB `thepit-nfs` PVC.
- `thepit-nfs` is root-squashed, so Grafana's startup ownership-reset init
  container is disabled; the Grafana pod uses its `fsGroup` instead.
- Alertmanager is intentionally disabled until there is an actionable,
  independent notification destination.
- Grafana is private to VLAN10 at `192.168.10.129`; it is not exposed through
  an Internet-facing route.
- Six official UniFi Poller Prometheus dashboards are pinned by Grafana.com
  dashboard ID and revision in the HelmRelease, under the `UniFi Poller`
  folder.

## Grafana access

The Grafana administrator credential is the external Kubernetes Secret
`observability/grafana-admin-credentials`; it is not stored in Git. The secret
keys are `admin-user` and `admin-password`.

Pi-hole manages `grafana.ericbisme.net` through ExternalDNS. From a workstation
on a permitted home VLAN, open <http://grafana.ericbisme.net>. The equivalent
temporary access path remains:

```sh
kubectl -n observability port-forward service/kube-prometheus-stack-grafana 3000:80
```

The chart provisions Prometheus and the standard Kubernetes dashboards
automatically. Do not add a public DNS record or Internet port-forward for the
administrative UI.
