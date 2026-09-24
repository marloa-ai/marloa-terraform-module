# cloudfront-app

CloudFront app edge (SPA on S3 + API via VPC origin).

Public edge for one environment: a single CloudFront distribution that
  - serves the dashboard SPA from a private S3 bucket (Origin Access Control)
  - forwards /api/* and /health to the internal ALB through a CloudFront VPC
    origin (private, no public ALB), uncached
with WAF attached. Same-origin API means no CORS preflights from the SPA.

Custom hostnames (e.g. app.marloa.in) are optional: pass `aliases` and an
ACM certificate ARN from us-east-1. Without them the *.cloudfront.net
hostname is used.

## Usage

```hcl
module "cloudfront_app" {
  source       = "git::ssh://git@github.com/marloa-ai/marloa-terraform-module.git//modules/cloudfront-app?ref=cloudfront-app-v0.1.0"

  name         = ...
  bucket_name  = ...
  alb_arn      = ...
  alb_dns_name = ...
  web_acl_arn  = ...
}
```

Pin `ref` to a released tag (`cloudfront-app-vX.Y.Z`); never a branch.

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
| [aws_cloudfront_distribution.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_function.spa_rewrite](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function) | resource |
| [aws_cloudfront_origin_access_control.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_cloudfront_response_headers_policy.security](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_response_headers_policy) | resource |
| [aws_cloudfront_vpc_origin.api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_vpc_origin) | resource |
| [aws_s3_bucket.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_cloudfront_cache_policy.disabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_cloudfront_cache_policy.optimized](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_cloudfront_origin_request_policy.all_viewer_except_host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_origin_request_policy) | data source |
| [aws_iam_policy_document.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| alb\_arn | Internal ALB exposed through the VPC origin. | `string` | n/a | yes |
| alb\_dns\_name | Internal DNS name of that ALB. | `string` | n/a | yes |
| bucket\_name | Globally unique name of the dashboard bucket. | `string` | n/a | yes |
| name | Name prefix for edge resources. | `string` | n/a | yes |
| web\_acl\_arn | CloudFront-scoped WAF web ACL ARN. | `string` | n/a | yes |
| acm\_certificate\_arn | us-east-1 certificate covering `aliases`. Required when aliases are set. | `string` | `null` | no |
| aliases | Custom hostnames for the distribution. | `list(string)` | `[]` | no |
| api\_path\_patterns | Paths forwarded to the API instead of S3. | `list(string)` | <pre>[<br/>  "/api/*",<br/>  "/health"<br/>]</pre> | no |
| origin\_read\_timeout | Seconds CloudFront waits for the API. 60 is the default quota and covers the 45 s outbound call wait. | `number` | `60` | no |
| price\_class | CloudFront price class (PriceClass\_200 includes India). | `string` | `"PriceClass_200"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| all\_urls | Every URL the dashboard is served on (CORS origins). |
| bucket\_name | S3 bucket holding the dashboard build. |
| distribution\_id | CloudFront distribution ID (for invalidations). |
| domain\_name | CloudFront hostname. |
| url | Primary public URL (first alias, else the CloudFront hostname). |
<!-- END_TF_DOCS -->
