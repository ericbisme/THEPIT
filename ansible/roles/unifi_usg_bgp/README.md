# USG BGP override

This role stages the minimal controller-side `config.gateway.json` required for
MetalLB BGP. It is intentionally limited to `protocols.bgp`: it does not copy
the historical DNS, WAN, VPN, or firewall settings from the retired Cloud Key
role.

Run it from the THEPIT Ansible directory:

```sh
set -a; source ~/codex.env; set +a
ansible-playbook -i inventory unifi-usg-bgp.yml --check
ansible-playbook -i inventory unifi-usg-bgp.yml
```

The role only stages the file at
`/data/unifi/data/sites/default/config.gateway.json`. It never provisions the
USG. After a reviewed run, explicitly provision `USG-Pro-4` from the UniFi UI.
Then verify the BGP session before creating a `LoadBalancer` Service.
