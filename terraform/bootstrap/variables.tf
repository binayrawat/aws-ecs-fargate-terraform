variable "project" {
  description = "Project name. Prefixes the state bucket, ECR repository and IAM roles."
  type        = string
  default     = "ecs-fargate-demo"
}

variable "region" {
  description = "AWS region for everything in this project."
  type        = string
  default     = "eu-central-1"
}

variable "github_repository" {
  description = "GitHub repository allowed to deploy, as owner/name."
  type        = string
  default     = "binayrawat/aws-ecs-fargate-terraform"
}

variable "github_environments" {
  description = "GitHub deployment environments whose jobs may assume the deploy role."
  type        = list(string)
  default     = ["dev"]
}

variable "create_github_oidc_provider" {
  description = "Create the GitHub OIDC provider. Set false if the account already has one (only one is allowed per account)."
  type        = bool
  default     = true
}

variable "ecr_images_to_keep" {
  description = "Number of images to keep in ECR before older ones expire."
  type        = number
  default     = 20
}
