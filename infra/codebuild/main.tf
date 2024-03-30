
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild_role" {
  name_prefix = "${var.project_name}-${var.project_env}-codebuild"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "permissions" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]

    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateNetworkInterfacePermission"]
    resources = ["arn:aws:ec2:${var.aws_region}:${var.account_id}:network-interface/*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }
  }


}

resource "aws_iam_role_policy" "this" {
  role   = aws_iam_role.codebuild_role.name
  policy = data.aws_iam_policy_document.permissions.json
}

resource "aws_codebuild_project" "this" {
  name          = "${var.project_name}-${var.project_env}"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "NO_CACHE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true


    dynamic "environment_variable" {
      for_each = {
        "AWS_ACCESS_KEY_ID"     = var.AWS_ACCESS_KEY_ID
        "AWS_ACCESS_KEY_SECRET" = var.AWS_ACCESS_KEY_SECRET
        "AWS_PROFILE"           = var.aws_profile
        "AWS_REGION"            = var.aws_region
        "AWS_ACCOUNT_ID"        = var.account_id
        "OPENAI_API_KEY"        = var.OPENAI_API_KEY
      }
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }

  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

  }

  source {
    type            = "GITHUB"
    location        = var.repository_url
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = false
    }
  }

  source_version = "master"

}


# resource "aws_codebuild_webhook" "this" {
#   project_name = aws_codebuild_project.this.name
#   build_type   = "BUILD"
#   filter_group {
#     filter {
#       type    = "EVENT"
#       pattern = "PUSH"
#     }

#     filter {
#       type    = "HEAD_REF"
#       pattern = "^refs/heads/master"
#     }
#   }
# }