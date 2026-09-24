# vpc

VPC.

VPC for one environment: 2 AZs, public subnets (NAT, future LiveKit media),
private subnets (ECS tasks, RDS, internal ALB), a single NAT gateway to start
(its EIP is the static egress IP clients can allowlist), a free S3 gateway
endpoint, and optional interface endpoints.

## Usage

```hcl
module "vpc" {
  source               = "git::ssh://git@github.com/marloa-ai/marloa-terraform-module.git//modules/vpc?ref=vpc-v0.1.0"

  name                 = ...
  cidr                 = ...
  azs                  = ...
  public_subnet_cidrs  = ...
  private_subnet_cidrs = ...
  kms_key_arn          = ...
}
```

Pin `ref` to a released tag (`vpc-vX.Y.Z`); never a branch.

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
| [aws_cloudwatch_log_group.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_default_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_flow_log.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_role.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.interface](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_security_group_ingress_rule.endpoints_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_iam_policy_document.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.flow_logs_trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| azs | Availability zones. | `list(string)` | n/a | yes |
| cidr | VPC CIDR block. | `string` | n/a | yes |
| kms\_key\_arn | KMS key encrypting the flow log group. | `string` | n/a | yes |
| name | Name prefix for network resources. | `string` | n/a | yes |
| private\_subnet\_cidrs | Private subnet CIDRs, one per AZ. | `list(string)` | n/a | yes |
| public\_subnet\_cidrs | Public subnet CIDRs, one per AZ. | `list(string)` | n/a | yes |
| enable\_interface\_endpoints | Create interface endpoints so ECR pulls, secrets and logs skip NAT. Costs roughly USD 7/month per endpoint per AZ. | `bool` | `false` | no |
| flow\_logs\_retention\_days | CloudWatch retention for VPC flow logs. | `number` | `30` | no |
| flow\_logs\_traffic\_type | VPC flow log capture: ALL, ACCEPT, REJECT, or null to disable. | `string` | `"ALL"` | no |
| interface\_endpoints | Interface endpoint service suffixes to create. | `list(string)` | <pre>[<br/>  "ecr.api",<br/>  "ecr.dkr",<br/>  "secretsmanager",<br/>  "logs",<br/>  "ssm"<br/>]</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| nat\_public\_ip | Static egress IP for client allowlists. |
| private\_subnet\_ids | Private subnet IDs. |
| public\_subnet\_ids | Public subnet IDs. |
| vpc\_cidr | VPC CIDR block. |
| vpc\_id | VPC ID. |
<!-- END_TF_DOCS -->
