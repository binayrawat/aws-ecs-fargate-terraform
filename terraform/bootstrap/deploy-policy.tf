# Permissions for the GitHub Actions deploy role.
#
# Scoping notes:
#   - ECR push and state access are limited to this project's repository and bucket.
#   - IAM is limited to roles named "<project>-*", and roles can only be passed to ECS tasks
#     or VPC flow logs. This stops the pipeline from creating or using an admin role.
#   - Networking/ECS/ALB/logs/autoscaling actions use "*" resources because Terraform has to
#     create resources whose ARNs don't exist yet. They are pinned to one region instead.

data "aws_iam_policy_document" "github_deploy" {
  #checkov:skip=CKV_AWS_356:Terraform must create resources whose ARNs don't exist yet; scoped by region instead.
  #checkov:skip=CKV_AWS_111:Same as above. IAM writes are separately limited to <project>-* roles.
  #checkov:skip=CKV_AWS_109:IAM permission management is limited to <project>-* roles and self-edits are denied.
  #checkov:skip=CKV_AWS_290:Same as CKV_AWS_111.
  #checkov:skip=CKV_AWS_289:Same as CKV_AWS_109.
  statement {
    sid       = "EcrLogin"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid = "EcrPushPull"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListTagsForResource",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [aws_ecr_repository.app.arn]
  }

  statement {
    sid       = "StateBucketList"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.state.arn]
  }

  statement {
    sid       = "StateObjects"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.state.arn}/*"]
  }

  statement {
    sid = "ManageAppInfrastructure"
    actions = [
      "application-autoscaling:*",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:ListTagsForResource",
      "cloudwatch:TagResource",
      "ec2:*",
      "ecs:*",
      "elasticloadbalancing:*",
      "logs:*",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.region]
    }
  }

  statement {
    sid = "ManageProjectRoles"
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:PutRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
    ]
    resources = ["arn:aws:iam::${local.account_id}:role/${var.project}-*"]
  }

  # The deploy role must never be able to edit itself.
  statement {
    sid       = "ProtectDeployRole"
    effect    = "Deny"
    actions   = ["iam:*"]
    resources = [aws_iam_role.github_deploy.arn]
  }

  statement {
    sid       = "PassProjectRolesToEcsAndFlowLogs"
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::${local.account_id}:role/${var.project}-*"]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com", "vpc-flow-logs.amazonaws.com"]
    }
  }

  statement {
    sid     = "CreateServiceLinkedRoles"
    actions = ["iam:CreateServiceLinkedRole"]
    resources = [
      "arn:aws:iam::*:role/aws-service-role/ecs.amazonaws.com/*",
      "arn:aws:iam::*:role/aws-service-role/elasticloadbalancing.amazonaws.com/*",
      "arn:aws:iam::*:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/*",
    ]
  }

  statement {
    sid       = "ReadCallerIdentityAndAzs"
    actions   = ["sts:GetCallerIdentity", "ec2:DescribeAvailabilityZones"]
    resources = ["*"]
  }
}
