# kms

KMS key.

One customer-managed KMS key per environment for RDS, Secrets Manager and
CloudWatch Logs and SNS. IAM policies grant use; the key policy delegates to
IAM and additionally lets CloudWatch Logs encrypt this account's log groups
and CloudWatch alarms publish to the encrypted alarm topic.

## Usage

```hcl
module "kms" {
  source = "git::ssh://git@github.com/marloa-ai/marloa-terraform-module.git//modules/kms?ref=kms-v0.1.0"

  name   = ...
}
```

Pin `ref` to a released tag (`kms-vX.Y.Z`); never a branch.

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
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cloudwatch_alarms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.combined](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| name | Key alias suffix, e.g. marloa-staging. | `string` | n/a | yes |
| deletion\_window\_in\_days | Waiting period before a scheduled key deletion completes. | `number` | `30` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| key\_arn | KMS key ARN. |
| key\_id | KMS key ID. |
<!-- END_TF_DOCS -->
