# Home Assistant

Home Assistant runs on `k8s-node1` with its configuration on a 5 GiB
`thepit-nfs` PVC. It is private to VLAN10 at
<http://homeassistant.ericbisme.net> (`192.168.10.130`). No Google credentials
are stored in Git.

## First-run setup

1. Open the private URL and create the Home Assistant owner account.
2. Add the official **Google Nest** integration from Settings → Devices &
   services. It will guide the Google Cloud, Device Access, OAuth, and Pub/Sub
   setup.
3. After Nest entities appear, enable Home Assistant's Prometheus integration
   and add a ServiceMonitor in this application so Prometheus can scrape
   `/api/prometheus`.

The Google Device Access project and OAuth credentials remain external to this
repository. Home Assistant's configuration PVC is persistent but is not a
backup; export Home Assistant backups separately once the integration is in
use.
