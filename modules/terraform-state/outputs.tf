output "bucket_name" {
  description = "State bucket name."
  value       = aws_s3_bucket.state.id
}

output "bucket_arn" {
  description = "State bucket ARN."
  value       = aws_s3_bucket.state.arn
}

output "kms_key_arn" {
  description = "KMS key encrypting state objects."
  value       = aws_kms_key.state.arn
}
