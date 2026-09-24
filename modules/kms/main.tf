# One customer-managed KMS key per environment for RDS, Secrets Manager and
# CloudWatch Logs and SNS. IAM policies grant use; the key policy delegates to
# IAM and additionally lets CloudWatch Logs encrypt this account's log groups
# and CloudWatch alarms publish to the encrypted alarm topic.

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "key" {
  statement {
    sid       = "AccountAdmin"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid = "CloudWatchLogs"
    actions = [
      "kms:Decrypt*",
      "kms:Describe*",
      "kms:Encrypt*",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.region}.amazonaws.com"]
    }
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:*"]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_alarms" {
  statement {
    sid       = "CloudWatchAlarmsToEncryptedSns"
    actions   = ["kms:Decrypt", "kms:GenerateDataKey*"]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

data "aws_iam_policy_document" "combined" {
  source_policy_documents = [
    data.aws_iam_policy_document.key.json,
    data.aws_iam_policy_document.cloudwatch_alarms.json,
  ]
}

resource "aws_kms_key" "this" {
  description             = "${var.name} data encryption (RDS, Secrets Manager, logs)"
  enable_key_rotation     = true
  deletion_window_in_days = var.deletion_window_in_days
  policy                  = data.aws_iam_policy_document.combined.json
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.this.key_id
}
