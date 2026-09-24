# terraform-state

Terraform state bucket.

S3 bucket for Terraform remote state. Locking uses S3-native lock files
(`use_lockfile = true` in the backend block, Terraform >= 1.11), so there is
no DynamoDB lock table.

## Usage

```hcl
module "terraform_state" {
  source      = "git::ssh://git@github.com/marloa-ai/marloa-terraform-module.git//modules/terraform-state?ref=terraform-state-v0.1.0"

  bucket_name = ...
  kms_alias   = ...
}
```

Pin `ref` to a released tag (`terraform-state-vX.Y.Z`); never a branch.

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
| [aws_kms_alias.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| bucket\_name | Globally unique name for the state bucket. | `string` | n/a | yes |
| kms\_alias | Alias (without alias/) for the state encryption key; referenced by backend blocks. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| bucket\_arn | State bucket ARN. |
| bucket\_name | State bucket name. |
| kms\_key\_arn | KMS key encrypting state objects. |
<!-- END_TF_DOCS -->
