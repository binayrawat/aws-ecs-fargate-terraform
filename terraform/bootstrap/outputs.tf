output "state_bucket" {
  description = "Set as the TF_STATE_BUCKET repository variable in GitHub."
  value       = aws_s3_bucket.state.bucket
}

output "ecr_repository_url" {
  description = "Image repository the pipeline pushes to."
  value       = aws_ecr_repository.app.repository_url
}

output "github_deploy_role_arn" {
  description = "Set as the AWS_ROLE_ARN repository variable in GitHub."
  value       = aws_iam_role.github_deploy.arn
}

output "region" {
  description = "Set as the AWS_REGION repository variable in GitHub."
  value       = var.region
}
