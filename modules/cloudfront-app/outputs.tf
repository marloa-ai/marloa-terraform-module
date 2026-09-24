output "distribution_id" {
  description = "CloudFront distribution ID (for invalidations)."
  value       = aws_cloudfront_distribution.this.id
}

output "domain_name" {
  description = "CloudFront hostname."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "url" {
  description = "Primary public URL (first alias, else the CloudFront hostname)."
  value       = "https://${length(var.aliases) > 0 ? var.aliases[0] : aws_cloudfront_distribution.this.domain_name}"
}

output "all_urls" {
  description = "Every URL the dashboard is served on (CORS origins)."
  value = concat(
    ["https://${aws_cloudfront_distribution.this.domain_name}"],
    [for a in var.aliases : "https://${a}"],
  )
}

output "bucket_name" {
  description = "S3 bucket holding the dashboard build."
  value       = aws_s3_bucket.web.id
}
