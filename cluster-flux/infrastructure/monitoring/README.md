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
- Grafana is intentionally cluster-internal. Do not expose the administrative
  UI through an Internet-facing route.

## Grafana access

The Grafana administrator credential is the external Kubernetes Secret
`observability/grafana-admin-credentials`; it is not stored in Git. The secret
keys are `admin-user` and `admin-password`.

From a workstation with the THEPIT kubeconfig:

```sh
kubectl -n observability port-forward service/kube-prometheus-stack-grafana 3000:80
```

Then open <http://127.0.0.1:3000>. The chart provisions Prometheus and the
standard Kubernetes dashboards automatically. A future private DNS/MetalLB
endpoint must be a separate reviewed change.
