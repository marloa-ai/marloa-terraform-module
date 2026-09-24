# ecr

ECR repositories.

Container image repositories. Tags are immutable (git SHA), images are
scanned on push, and other workload accounts (prod) may pull so the exact
image tested in staging is promoted without a rebuild.

## Usage

```hcl
module "ecr" {
  source       = "git::ssh://git@github.com/marloa-ai/marloa-terraform-module.git//modules/ecr?ref=ecr-v0.1.0"

  repositories = ...
}
```

Pin `ref` to a released tag (`ecr-vX.Y.Z`); never a branch.

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
| [aws_ecr_lifecycle_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [aws_iam_policy_document.cross_account_pull](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| repositories | Repository names to create, e.g. ["marloa/api"]. | `list(string)` | n/a | yes |
| keep\_tagged\_images | Number of tagged images to retain per repository. | `number` | `100` | no |
| pull\_account\_ids | Other AWS account IDs allowed to pull images. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| repository\_arns | Repository ARNs by name. |
| repository\_urls | Repository URLs by name. |
<!-- END_TF_DOCS -->
