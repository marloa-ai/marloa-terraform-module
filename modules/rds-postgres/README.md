# rds-postgres

RDS PostgreSQL.

One RDS PostgreSQL instance plus a Secrets Manager secret the app consumes.

The master password is generated as an ephemeral value and passed through
write-only arguments, so it never lands in Terraform state or plan output.
The secret holds JSON: username, password, host, port, dbname and `url`
(a ready-to-use DATABASE_URL with sslmode=require). To rotate, bump
`password_version` and apply, then restart the ECS services.

## Usage

```hcl
module "rds_postgres" {
  source      = "git::ssh://git@github.com/marloa-ai/marloa-terraform-module.git//modules/rds-postgres?ref=rds-postgres-v0.1.0"

  name        = ...
  secret_name = ...
  vpc_id      = ...
  subnet_ids  = ...
  kms_key_arn = ...
  db_name     = ...
  username    = ...
}
```

Pin `ref` to a released tag (`rds-postgres-vX.Y.Z`); never a branch.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.11 |
| aws | >= 6.0 |
| random | >= 3.7 |

## Providers

| Name | Version |
| ---- | ------- |
| aws | >= 6.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_parameter_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_ingress_rule.postgres](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| db\_name | Initial database name. | `string` | n/a | yes |
| kms\_key\_arn | KMS key for storage, Performance Insights and the secret. | `string` | n/a | yes |
| name | Instance identifier, e.g. marloa-staging-public. | `string` | n/a | yes |
| secret\_name | Secrets Manager name, e.g. marloa/staging/database/public. | `string` | n/a | yes |
| subnet\_ids | Private subnets for the DB subnet group. | `list(string)` | n/a | yes |
| username | Master username. | `string` | n/a | yes |
| vpc\_id | VPC of the instance. | `string` | n/a | yes |
| allocated\_storage | Initial storage in GiB. | `number` | `20` | no |
| allowed\_security\_group\_ids | Security groups allowed to reach 5432. | `map(string)` | `{}` | no |
| apply\_immediately | Apply modifications immediately instead of in the maintenance window. | `bool` | `false` | no |
| backup\_retention\_days | Backup / PITR retention in days. | `number` | `7` | no |
| deletion\_protection | Protect from deletion. | `bool` | `true` | no |
| engine\_version | PostgreSQL version (major pins the family). | `string` | `"17"` | no |
| instance\_class | Instance class. | `string` | `"db.t4g.small"` | no |
| log\_min\_duration\_ms | Log statements slower than this many milliseconds (-1 disables). | `number` | `1000` | no |
| log\_retention\_days | CloudWatch retention for exported PostgreSQL logs. | `number` | `30` | no |
| max\_allocated\_storage | Storage autoscaling ceiling in GiB. | `number` | `100` | no |
| multi\_az | Run Multi-AZ. | `bool` | `false` | no |
| password\_version | Increment to generate and set a new master password. | `number` | `1` | no |
| secret\_recovery\_window\_days | Days a deleted secret can be restored (0 = force delete). | `number` | `7` | no |
| skip\_final\_snapshot | Skip the final snapshot on deletion. | `bool` | `false` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| address | RDS endpoint hostname. |
| instance\_id | RDS instance identifier. |
| secret\_arn | Secret with connection details and DATABASE\_URL. |
| security\_group\_id | Security group of the instance. |
<!-- END_TF_DOCS -->
