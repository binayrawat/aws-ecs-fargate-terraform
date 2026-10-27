variable "project" {
  description = "Project name. Must match the bootstrap stack (it names the ECR repository)."
  type        = string
  default     = "ecs-fargate-demo"
}

variable "environment" {
  description = "Environment name, used in resource names and tags."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for this environment's VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "image_tag" {
  description = "Image tag to deploy. CI passes the Git commit SHA."
  type        = string
}

variable "enable_nat_gateway" {
  description = "Run tasks in private subnets behind a NAT gateway (~$35/month). Set false for a cheaper lab setup."
  type        = bool
  default     = true
}

variable "certificate_arn" {
  description = "Optional ACM certificate ARN to serve HTTPS."
  type        = string
  default     = null
}
