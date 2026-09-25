output "service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.this.name
}

output "task_family" {
  description = "Task definition family CI registers revisions under."
  value       = aws_ecs_task_definition.this.family
}

output "container_name" {
  description = "Name of the app container whose image CI replaces."
  value       = local.container_name
}

output "security_group_id" {
  description = "Security group of the tasks."
  value       = aws_security_group.this.id
}

output "target_group_arn_suffix" {
  description = "Target group ARN suffix for CloudWatch dimensions (null without a load balancer)."
  value       = one(aws_lb_target_group.this[*].arn_suffix)
}

output "log_group_name" {
  description = "CloudWatch log group of the tasks."
  value       = aws_cloudwatch_log_group.this.name
}
