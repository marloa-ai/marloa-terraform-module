# Internal Application Load Balancer in private subnets. It is reachable only
# through a CloudFront VPC origin (see the cloudfront-app module), so it has no public IP,
# no public listener, and TLS terminates at CloudFront.

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group" "this" {
  name_prefix = "${var.name}-alb-"
  description = "Internal ALB, reachable from CloudFront VPC origins"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "cloudfront" {
  security_group_id = aws_security_group.this.id
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cloudfront.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  description       = "CloudFront origin-facing"
}

resource "aws_vpc_security_group_egress_rule" "vpc" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = var.vpc_cidr
  ip_protocol       = "-1"
  description       = "To targets inside the VPC"
}

resource "aws_lb" "this" {
  name                       = var.name
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.this.id]
  subnets                    = var.subnet_ids
  idle_timeout               = var.idle_timeout
  drop_invalid_header_fields = true
  enable_deletion_protection = var.deletion_protection
}

# Internal-only ALB reached through a CloudFront VPC origin over the AWS
# network; TLS terminates at CloudFront.
#trivy:ignore:AVD-AWS-0054
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "application/json"
      message_body = "{\"detail\":\"Not Found\"}"
      status_code  = "404"
    }
  }
}
