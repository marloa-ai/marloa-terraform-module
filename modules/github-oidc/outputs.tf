output "oidc_provider_arn" {
  description = "GitHub OIDC provider ARN."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "role_arns" {
  description = "CI role ARNs by purpose."
  value = {
    tf_plan  = aws_iam_role.tf_plan.arn
    tf_apply = aws_iam_role.tf_apply.arn
    deploy   = aws_iam_role.deploy.arn
    ecr_push = one(aws_iam_role.ecr_push[*].arn)
  }
}
