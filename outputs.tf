output "cloudfront_domain" {
  value       = aws_cloudfront_distribution.frontend.domain_name
  description = "Domain name of the CloudFront distribution"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.frontend.bucket
  description = "Name of the S3 bucket hosting the frontend"
}
output "aws_cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.frontend.id
}

output "ec2_public_dns" {
  value       = aws_instance.api_server.public_dns
  description = "Public DNS name of the EC2 instance"
}

output "ecr_registry_url" {
  value = "${aws_ecr_repository.api.registry_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}

output "ec2_instance_id" {
  value = aws_instance.api_server.id
}

output "ecr_repository" {
  value = aws_ecr_repository.api.name
}

output "db_host" {
  description = "PostgreSQL database endpoint"
  value       = aws_db_instance.rock_of_ages.address
}

output "db_name" {
  description = "database name"
  value       = aws_db_instance.rock_of_ages.db_name
}

output "db_user" {
  description = "database username"
  value       = aws_db_instance.rock_of_ages.username
}

output "github_oidc_role_arn" {
  description = "ARN of the IAM role used by GitHub OIDC"
  value       = aws_iam_role.github_oidc.arn
}

