output "arn" {
  description = "ALB ARN."
  value       = aws_lb.this.arn
}

output "arn_suffix" {
  description = "ALB ARN suffix, used in CloudWatch dimensions."
  value       = aws_lb.this.arn_suffix
}

output "dns_name" {
  description = "Internal DNS name of the ALB."
  value       = aws_lb.this.dns_name
}

output "security_group_id" {
  description = "Security group of the ALB."
  value       = aws_security_group.this.id
}

output "listener_arn" {
  description = "HTTP listener ARN services attach rules to."
  value       = aws_lb_listener.http.arn
}
