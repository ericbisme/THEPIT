output "access_key_id" {
  description = "Access key ID to place in the ClusterIssuer after reviewing auth."
  value       = aws_iam_access_key.cert_manager.id
  sensitive   = true
}

output "secret_access_key" {
  description = "Secret access key; never commit or paste into Git."
  value       = aws_iam_access_key.cert_manager.secret
  sensitive   = true
}

output "iam_user_arn" {
  value = aws_iam_user.cert_manager.arn
}
