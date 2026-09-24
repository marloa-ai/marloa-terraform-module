# GitHub Actions OIDC provider and the CI roles for one workload account.
#
# Resource-scoped permissions follow the naming convention
# `<project>-<environment>-*` (ECS, IAM, logs, S3), secrets under `<project>/`
# and SSM parameters under `/<project>/<environment>/`.
#
#   gha-tf-plan   read-only plan for the infra repo (PRs and main)
#   gha-tf-apply  apply for the infra repo, only from the GitHub Environment
#                 that matches this account (staging / prod)
#   gha-deploy    app deploys from the app repo, same Environment scoping
#   gha-ecr-push  image pushes from the app repo's main branch (only created
#                 in the account that hosts ECR)
#
# No long-lived keys: every role is assumed with a GitHub OIDC token.

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region
  name       = "${var.project}-${var.environment}"

  # Subject prefixes per repo. Orgs with immutable OIDC subjects issue
  # repo:<owner>@<owner_id>/<repo>@<repo_id>:...; the legacy form
  # repo:<owner>/<repo>:... is always accepted as well.
  infra = compact([
    "repo:${var.github_org}/${var.infra_repo}",
    var.github_ids == null ? "" : "repo:${var.github_org}@${var.github_ids.org}/${var.infra_repo}@${var.github_ids.infra_repo}",
  ])
  app = compact([
    "repo:${var.github_org}/${var.app_repo}",
    var.github_ids == null ? "" : "repo:${var.github_org}@${var.github_ids.org}/${var.app_repo}@${var.github_ids.app_repo}",
  ])
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "trust" {
  for_each = {
    plan     = flatten([for p in local.infra : ["${p}:pull_request", "${p}:ref:refs/heads/main"]])
    apply    = [for p in local.infra : "${p}:environment:${var.environment}"]
    deploy   = [for p in local.app : "${p}:environment:${var.environment}"]
    ecr_push = [for p in local.app : "${p}:ref:refs/heads/main"]
  }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = each.value
    }
  }
}

# --- Terraform plan (read-only) ----------------------------------------------

resource "aws_iam_role" "tf_plan" {
  name                 = "gha-tf-plan"
  assume_role_policy   = data.aws_iam_policy_document.trust["plan"].json
  max_session_duration = 3600
}

resource "aws_iam_role_policy_attachment" "tf_plan_readonly" {
  role       = aws_iam_role.tf_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

data "aws_iam_policy_document" "tf_plan" {
  statement {
    sid       = "StateList"
    actions   = ["s3:ListBucket"]
    resources = [var.state_bucket_arn]
  }
  statement {
    sid       = "StateRead"
    actions   = ["s3:GetObject"]
    resources = ["${var.state_bucket_arn}/*"]
  }
  statement {
    sid       = "StateLock"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["${var.state_bucket_arn}/*.tflock"]
  }
  statement {
    sid       = "StateEncryption"
    actions   = ["kms:Decrypt", "kms:Encrypt", "kms:GenerateDataKey"]
    resources = [var.state_kms_key_arn]
  }
  # Refreshing aws_secretsmanager_secret_version reads the value.
  statement {
    sid       = "ReadManagedSecrets"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:${var.project}/*"]
  }
  statement {
    sid       = "DecryptViaSecretsManager"
    actions   = ["kms:Decrypt"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["secretsmanager.${local.region}.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "tf_plan" {
  name   = "terraform-plan"
  role   = aws_iam_role.tf_plan.id
  policy = data.aws_iam_policy_document.tf_plan.json
}

# --- Terraform apply -----------------------------------------------------------

resource "aws_iam_role" "tf_apply" {
  name                 = "gha-tf-apply"
  assume_role_policy   = data.aws_iam_policy_document.trust["apply"].json
  max_session_duration = 7200
}

resource "aws_iam_role_policy_attachment" "tf_apply_admin" {
  role       = aws_iam_role.tf_apply.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# --- App deploy ----------------------------------------------------------------

data "aws_iam_policy_document" "deploy" {
  statement {
    sid       = "ReadDeployParameters"
    actions   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
    resources = ["arn:aws:ssm:${local.region}:${local.account_id}:parameter/${var.project}/${var.environment}/*"]
  }
  statement {
    sid = "TaskDefinitions"
    actions = [
      "ecs:DescribeTaskDefinition",
      "ecs:ListTaskDefinitions",
      "ecs:RegisterTaskDefinition",
    ]
    resources = ["*"]
  }
  statement {
    sid       = "Services"
    actions   = ["ecs:DescribeServices", "ecs:UpdateService"]
    resources = ["arn:aws:ecs:${local.region}:${local.account_id}:service/${local.name}/*"]
  }
  statement {
    sid       = "RunMigrationTask"
    actions   = ["ecs:RunTask"]
    resources = ["arn:aws:ecs:${local.region}:${local.account_id}:task-definition/${local.name}-*:*"]
  }
  statement {
    sid       = "Tasks"
    actions   = ["ecs:DescribeTasks", "ecs:StopTask"]
    resources = ["arn:aws:ecs:${local.region}:${local.account_id}:task/${local.name}/*"]
  }
  statement {
    sid       = "PassTaskRoles"
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::${local.account_id}:role/${local.name}-*"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
  statement {
    sid       = "ReadTaskLogs"
    actions   = ["logs:GetLogEvents", "logs:FilterLogEvents"]
    resources = ["arn:aws:logs:${local.region}:${local.account_id}:log-group:/ecs/${local.name}/*"]
  }
  statement {
    sid       = "FrontendBucketList"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${local.name}-web-*"]
  }
  statement {
    sid       = "FrontendBucketObjects"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${local.name}-web-*/*"]
  }
  statement {
    sid       = "CloudFrontInvalidation"
    actions   = ["cloudfront:CreateInvalidation", "cloudfront:GetInvalidation"]
    resources = ["arn:aws:cloudfront::${local.account_id}:distribution/*"]
  }
}

resource "aws_iam_role" "deploy" {
  name                 = "gha-deploy"
  assume_role_policy   = data.aws_iam_policy_document.trust["deploy"].json
  max_session_duration = 3600
}

resource "aws_iam_role_policy" "deploy" {
  name   = "app-deploy"
  role   = aws_iam_role.deploy.id
  policy = data.aws_iam_policy_document.deploy.json
}

# --- ECR push (registry account only) ------------------------------------------

data "aws_iam_policy_document" "ecr_push" {
  count = length(var.ecr_repository_arns) > 0 ? 1 : 0

  statement {
    sid       = "Login"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
  statement {
    sid = "Push"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = var.ecr_repository_arns
  }
}

resource "aws_iam_role" "ecr_push" {
  count = length(var.ecr_repository_arns) > 0 ? 1 : 0

  name                 = "gha-ecr-push"
  assume_role_policy   = data.aws_iam_policy_document.trust["ecr_push"].json
  max_session_duration = 3600
}

resource "aws_iam_role_policy" "ecr_push" {
  count = length(var.ecr_repository_arns) > 0 ? 1 : 0

  name   = "ecr-push"
  role   = aws_iam_role.ecr_push[0].id
  policy = data.aws_iam_policy_document.ecr_push[0].json
}
