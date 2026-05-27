#############################
# IAM Role for EC2 Access
#############################
resource "aws_iam_role" "ec2_access_role" {
  name = "Ec2AccessRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
#############################
# Attach ECR Read-Only Policy
#############################
resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ec2_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
#############################
# Attach SSM Access Policy
#############################
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
#############################
# Create Instance Profile
#############################
resource "aws_iam_instance_profile" "ec2_access_instance_profile" {
  name = "Ec2AccessRoleInstanceProfile"
  role = aws_iam_role.ec2_access_role.name
}
#############################
# GitHub OIDC Provider
#############################
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = [
    "sts.amazonaws.com"
  ]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1" # GitHub's OIDC thumbprint
  ]
}
#############################
# Trust Policy for GitHub OIDC
#############################
data "aws_iam_policy_document" "github_oidc_trust" {
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
      values   = ["repo:${var.github_org}/*"]
    }
  }
}
#############################
# IAM Role
#############################
resource "aws_iam_role" "github_oidc" {
  name               = "github_oidc"
  assume_role_policy = data.aws_iam_policy_document.github_oidc_trust.json
  description        = "GitHub OIDC role"
}
#############################
# Attach AWS Managed Policies
#############################
locals {
  managed_policies = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/CloudFrontFullAccess"
  ]
}
resource "aws_iam_role_policy_attachment" "github_oidc_managed" {
  for_each = toset(local.managed_policies)
  role       = aws_iam_role.github_oidc.name
  policy_arn = each.value
}