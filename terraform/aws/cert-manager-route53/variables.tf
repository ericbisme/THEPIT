variable "aws_region" {
  description = "AWS region containing the Route 53 hosted zone."
  type        = string
  default     = "us-west-2"
}

variable "hosted_zone_id" {
  description = "The existing public Route 53 hosted zone ID for ericbisme.net."
  type        = string
  nullable    = false
}

variable "iam_user_name" {
  description = "IAM user used only by cert-manager's Route 53 DNS-01 solver."
  type        = string
  default     = "thepit-cert-manager-route53"
}
