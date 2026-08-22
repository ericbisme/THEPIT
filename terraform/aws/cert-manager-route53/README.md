# Route 53 access for cert-manager

This is preparation only. It creates a dedicated IAM user with the least privilege needed for
ACME DNS-01 records in the existing `ericbisme.net` hosted zone. Do not apply it until:

- the hosted-zone ID has been verified in AWS;
- Terraform state storage is protected (the state contains the generated secret access key); and
- the operator explicitly chooses this IAM-user approach over a different AWS credential path.

The old cluster used `us-west-2` and hosted zone `Z24FPOSZ13XYWF`; the zone ID remains a required
variable so it cannot be applied accidentally to the wrong zone.

Example, after authentication and state handling are ready:

```sh
terraform init
terraform plan -var='hosted_zone_id=Z24FPOSZ13XYWF'
terraform apply -var='hosted_zone_id=Z24FPOSZ13XYWF'
terraform output -raw access_key_id
terraform output -raw secret_access_key
```

The generated values belong in the Kubernetes Secret/issuer setup described in the cert-manager
README, never in this repository. Destroying this module revokes the IAM user key; treat that as
a planned, potentially service-impacting change.
