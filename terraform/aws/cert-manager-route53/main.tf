resource "aws_iam_user" "cert_manager" {
  name = var.iam_user_name
  path = "/thepit/"
}

resource "aws_iam_user_policy" "cert_manager_route53" {
  name = "route53-dns01-ericbisme"
  user = aws_iam_user.cert_manager.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ReadHostedZone"
        Effect   = "Allow"
        Action   = ["route53:GetHostedZone", "route53:ListResourceRecordSets"]
        Resource = "arn:aws:route53:::hostedzone/${var.hosted_zone_id}"
      },
      {
        Sid      = "ChangeAcmeRecords"
        Effect   = "Allow"
        Action   = "route53:ChangeResourceRecordSets"
        Resource = "arn:aws:route53:::hostedzone/${var.hosted_zone_id}"
        Condition = {
          "ForAllValues:StringLike" = {
            "route53:ChangeResourceRecordSetsNormalizedRecordNames" = [
              "_acme-challenge.ericbisme.net",
              "_acme-challenge.*.ericbisme.net"
            ]
          }
        }
      },
      {
        Sid      = "ReadChangeStatus"
        Effect   = "Allow"
        Action   = "route53:GetChange"
        Resource = "arn:aws:route53:::change/*"
      }
    ]
  })
}

# This creates a secret in Terraform state. Do not apply until state storage is protected.
resource "aws_iam_access_key" "cert_manager" {
  user = aws_iam_user.cert_manager.name
}
