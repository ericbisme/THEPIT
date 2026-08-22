# cert-manager

This installs cert-manager 1.21.1 through Flux. It installs the controller and CRDs only;
Route 53 credentials and ACME issuers are intentionally staged separately until AWS auth is
approved and a secure Terraform state location is chosen.

The old cluster used Route 53 DNS-01 for `ericbisme.net`, with hosted zone ID
`Z24FPOSZ13XYWF`, region `us-west-2`, and separate staging/production issuers. That configuration
is a design reference only. Its access key material is not being migrated.

After AWS auth is deliberately set up:

1. Apply `terraform/aws/cert-manager-route53` with the verified hosted-zone ID.
2. Create `cert-manager-route53-ericbisme` in namespace `cert-manager` with the generated secret
   access key. Keep the secret and Terraform state out of Git.
3. Add the issuer manifest from `examples/issuers.yaml`, replacing the access-key placeholder,
   and validate with a staging Certificate before enabling production.

Let's Encrypt HTTP-01 is not suitable for the private MetalLB addresses in this cluster; Route 53
DNS-01 is the intended challenge mechanism.
