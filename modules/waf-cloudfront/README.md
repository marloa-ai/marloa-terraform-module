# waf-cloudfront

WAF web ACL for CloudFront.

WAF web ACL for CloudFront (must be created in us-east-1; pass that
provider in). Per-IP rate limit plus AWS managed baseline rule groups.

## Usage

```hcl
module "waf_cloudfront" {
  source = "git::ssh://git@github.com/marloa-ai/marloa-terraform-module.git//modules/waf-cloudfront?ref=waf-cloudfront-v0.1.0"
  providers = { aws = aws.us_east_1 }

  name   = ...
}
```

Pin `ref` to a released tag (`waf-cloudfront-vX.Y.Z`); never a branch.

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
| [aws_wafv2_web_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| name | Web ACL name. | `string` | n/a | yes |
| rate\_limit\_per\_5min | Requests per 5 minutes per client IP before blocking. | `number` | `2000` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| arn | Web ACL ARN. |
<!-- END_TF_DOCS -->
