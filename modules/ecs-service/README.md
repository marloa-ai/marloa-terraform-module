# ecs-service

ECS Fargate service.

Fargate (ARM64) service behind the internal ALB.

Terraform owns the task definition shape (env, secrets, sizing, roles). CI
owns the image: deploys copy the latest revision, swap the image of the
container named "app", register a new revision and update the service. The
service therefore ignores task_definition and desired_count drift.

## Usage

```hcl
module "ecs_service" {
  source                 = "git::ssh://git@github.com/marloa-ai/marloa-terraform-module.git//modules/ecs-service?ref=ecs-service-v0.1.0"

  name                   = ...
  cluster_arn            = ...
  cluster_name           = ...
  vpc_id                 = ...
  subnet_ids             = ...
  image                  = ...
  kms_key_arn            = ...
  alb_security_group_id  = ...
  alb_arn_suffix         = ...
  listener_arn           = ...
  listener_rule_priority = ...
}
```

Pin `ref` to a released tag (`ecs-service-vX.Y.Z`); never a branch.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.11 |
| aws | >= 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| aws | >= 6.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_appautoscaling_policy.cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.requests](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.execution_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.execution_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb_listener_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.from_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_iam_policy_document.ecs_tasks_trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.execution_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| alb\_arn\_suffix | ALB ARN suffix for request-count scaling. | `string` | n/a | yes |
| alb\_security\_group\_id | ALB security group allowed to reach the tasks. | `string` | n/a | yes |
| cluster\_arn | ECS cluster ARN. | `string` | n/a | yes |
| cluster\_name | ECS cluster name. | `string` | n/a | yes |
| image | Initial image URI. Later deploys replace it from CI. | `string` | n/a | yes |
| kms\_key\_arn | Key for log group encryption and secret decryption. | `string` | n/a | yes |
| listener\_arn | ALB listener to attach the routing rule to. | `string` | n/a | yes |
| listener\_rule\_priority | Priority of the listener rule (unique per listener). | `number` | n/a | yes |
| name | Service name, e.g. marloa-staging-api. Also the task family. | `string` | n/a | yes |
| subnet\_ids | Private subnets for the tasks. | `list(string)` | n/a | yes |
| vpc\_id | VPC of the service. | `string` | n/a | yes |
| container\_port | Port the container listens on. | `number` | `8080` | no |
| cpu | Task CPU units (1024 = 1 vCPU). | `number` | `512` | no |
| cpu\_target\_percent | Average CPU to target when scaling. | `number` | `60` | no |
| desired\_count | Initial task count; autoscaling owns it afterwards. | `number` | `1` | no |
| egress\_rules | Outbound TCP rules for the tasks (port, IPv4 CIDR, description). | <pre>list(object({<br/>    port        = number<br/>    cidr        = string<br/>    description = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "cidr": "0.0.0.0/0",<br/>    "description": "HTTPS to AWS APIs and external services",<br/>    "port": 443<br/>  }<br/>]</pre> | no |
| environment | Plain environment variables. | `map(string)` | `{}` | no |
| health\_check\_path | Target group health check path. | `string` | `"/health"` | no |
| log\_retention\_days | CloudWatch log retention in days. | `number` | `30` | no |
| max\_capacity | Autoscaling maximum task count. | `number` | `2` | no |
| memory | Task memory in MiB. | `number` | `1024` | no |
| min\_capacity | Autoscaling minimum task count. | `number` | `1` | no |
| path\_patterns | Paths routed to this service. | `list(string)` | <pre>[<br/>  "/*"<br/>]</pre> | no |
| requests\_per\_target | ALB requests per target per minute before scaling out. | `number` | `1000` | no |
| secret\_arns | Secret ARNs the execution role may read. | `list(string)` | `[]` | no |
| secrets | Env var name => Secrets Manager valueFrom (ARN or ARN:json-key::). | `map(string)` | `{}` | no |
| stop\_timeout | Seconds to drain in-flight requests (outbound call setup waits up to 45 s). | `number` | `60` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| container\_name | Name of the app container whose image CI replaces. |
| log\_group\_name | CloudWatch log group of the tasks. |
| security\_group\_id | Security group of the tasks. |
| service\_name | ECS service name. |
| target\_group\_arn\_suffix | Target group ARN suffix for CloudWatch dimensions. |
| task\_family | Task definition family CI registers revisions under. |
<!-- END_TF_DOCS -->
