# UniFi controller audit

This role establishes a read-only baseline for the current UniFi Console before any controller
configuration is automated. It gathers standard Ansible facts, verifies the expected controller
hostname and required services, and checks historical `config.gateway.json` locations.

The role contains no package, file, service, command, shell, URI, or controller API mutations. Run
it in check mode as an additional regression guard:

```bash
ansible-playbook -i inventory unifi-controller-audit.yml --check
```

An unexpected hostname, operating system, Python major version, or stopped required service is a
stop condition for later mutating playbooks. An absent `config.gateway.json` is reported rather
than treated as a failure because the current controller does not have one.
