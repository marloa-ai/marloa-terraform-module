# alb

Internal Application Load Balancer.

Internal Application Load Balancer in private subnets. It is reachable only
through a CloudFront VPC origin (see the cloudfront-app module), so it has no public IP,
no public listener, and TLS terminates at CloudFront.

## Usage

```hcl
module "alb" {
  source     = "git::ssh://git@github.com/marloa-ai/marloa-terraform-module.git//modules/alb?ref=alb-v0.1.0"

  name       = ...
  vpc_id     = ...
  vpc_cidr   = ...
  subnet_ids = ...
}
```

Pin `ref` to a released tag (`alb-vX.Y.Z`); never a branch.

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
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_ec2_managed_prefix_list.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_managed_prefix_list) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| name | Name prefix for the ALB and its security group. | `string` | n/a | yes |
| subnet\_ids | Private subnets for the internal ALB. | `list(string)` | n/a | yes |
| vpc\_cidr | VPC CIDR the ALB may send traffic to. | `string` | n/a | yes |
| vpc\_id | VPC to place the ALB in. | `string` | n/a | yes |
| deletion\_protection | Protect the ALB from deletion. | `bool` | `false` | no |
| idle\_timeout | Seconds. Must exceed the 45 s outbound agent-ready wait. | `number` | `120` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| arn | ALB ARN. |
| arn\_suffix | ALB ARN suffix, used in CloudWatch dimensions. |
| dns\_name | Internal DNS name of the ALB. |
| listener\_arn | HTTP listener ARN services attach rules to. |
| security\_group\_id | Security group of the ALB. |
<!-- END_TF_DOCS -->
