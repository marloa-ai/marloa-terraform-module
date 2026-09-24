# observability

Baseline CloudWatch alarms.

Baseline alarms routed to an SNS topic. Sprint 2 adds structured logs,
OpenTelemetry/X-Ray, call-setup SLO alarms and Slack/PagerDuty wiring.

## Usage

```hcl
module "observability" {
  source         = "git::ssh://git@github.com/marloa-ai/marloa-terraform-module.git//modules/observability?ref=observability-v0.1.0"

  name           = ...
  db_instance_id = ...
  alb_arn_suffix = ...
  kms_key_arn    = ...
}
```

Pin `ref` to a released tag (`observability-vX.Y.Z`); never a branch.

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
| [aws_cloudwatch_metric_alarm.api_5xx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.api_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.api_unhealthy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.db_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.db_storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_sns_topic.alarms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| alb\_arn\_suffix | ALB ARN suffix for API alarms. | `string` | n/a | yes |
| db\_instance\_id | RDS instance to alarm on. | `string` | n/a | yes |
| kms\_key\_arn | KMS key encrypting the alarm topic. | `string` | n/a | yes |
| name | Name prefix for alarms and the topic. | `string` | n/a | yes |
| alarm\_emails | Email addresses subscribed to the topic. | `list(string)` | `[]` | no |
| api | API service details; null until the service exists. | <pre>object({<br/>    cluster_name            = string<br/>    service_name            = string<br/>    target_group_arn_suffix = string<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| sns\_topic\_arn | Alarm SNS topic ARN. |
<!-- END_TF_DOCS -->
