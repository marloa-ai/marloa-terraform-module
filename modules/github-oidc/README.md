# github-oidc

GitHub Actions OIDC provider and CI roles.

GitHub Actions OIDC provider and the CI roles for one workload account.

Resource-scoped permissions follow the naming convention
`<project>-<environment>-*` (ECS, IAM, logs, S3), secrets under `<project>/`
and SSM parameters under `/<project>/<environment>/`.

  gha-tf-plan   read-only plan for the infra repo (PRs and main)
  gha-tf-apply  apply for the infra repo, only from the GitHub Environment
                that matches this account (staging / prod)
  gha-deploy    app deploys from the app repo, same Environment scoping
  gha-ecr-push  image pushes from the app repo's main branch (only created
                in the account that hosts ECR)

No long-lived keys: every role is assumed with a GitHub OIDC token.

## Usage

```hcl
module "github_oidc" {
  source            = "git::ssh://git@github.com/marloa-ai/marloa-terraform-module.git//modules/github-oidc?ref=github-oidc-v0.1.0"

  project           = ...
  github_org        = ...
  infra_repo        = ...
  app_repo          = ...
  environment       = ...
  state_bucket_arn  = ...
  state_kms_key_arn = ...
}
```

Pin `ref` to a released tag (`github-oidc-vX.Y.Z`); never a branch.

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
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecr_push](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.tf_apply](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.tf_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ecr_push](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.tf_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.tf_apply_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.tf_plan_readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecr_push](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tf_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| app\_repo | Application monorepo name. | `string` | n/a | yes |
| environment | Deployment environment hosted in this account (staging or prod). Also the GitHub Environment name. | `string` | n/a | yes |
| github\_org | GitHub organization owning the repos. | `string` | n/a | yes |
| infra\_repo | Infra (Terraform) repository name. | `string` | n/a | yes |
| project | Project prefix used in resource names, secret and parameter paths (e.g. marloa). | `string` | n/a | yes |
| state\_bucket\_arn | Terraform state bucket the plan role may read and lock. | `string` | n/a | yes |
| state\_kms\_key\_arn | KMS key encrypting the state bucket. | `string` | n/a | yes |
| ecr\_repository\_arns | ECR repositories the app repo may push to. Empty = no push role in this account. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| oidc\_provider\_arn | GitHub OIDC provider ARN. |
| role\_arns | CI role ARNs by purpose. |
<!-- END_TF_DOCS -->
