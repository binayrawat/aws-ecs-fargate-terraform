variable "name" {
  description = "Name for the cluster, service, load balancer and related resources (max 32 characters for the ALB)."
  type        = string

  validation {
    condition     = length(var.name) <= 32
    error_message = "name must be 32 characters or fewer (ALB and target group name limit)."
  }
}

variable "region" {
  description = "AWS region, used by the awslogs log driver."
  type        = string
}

variable "vpc_id" {
  description = "VPC to deploy into."
  type        = string
}

variable "public_subnet_ids" {
  description = "Subnets for the internet-facing load balancer (at least two AZs)."
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "Subnets for the ECS tasks. Private subnets unless NAT is disabled."
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Give tasks a public IP. Only needed when tasks run in public subnets (no NAT gateway)."
  type        = bool
  default     = false
}

variable "image" {
  description = "Full container image reference, e.g. <account>.dkr.ecr.<region>.amazonaws.com/app:<git-sha>."
  type        = string
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "Fargate task CPU units (256 = 0.25 vCPU)."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate task memory in MiB."
  type        = number
  default     = 512
}

variable "environment" {
  description = "Plain-text environment variables for the container. Use Secrets Manager for secrets."
  type        = map(string)
  default     = {}
}

variable "health_check_path" {
  description = "Path the load balancer uses to check task health."
  type        = string
  default     = "/healthz"
}

variable "min_capacity" {
  description = "Minimum (and initial) number of running tasks."
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of running tasks under load."
  type        = number
  default     = 3
}

variable "cpu_target_percent" {
  description = "Average CPU utilisation that autoscaling aims for."
  type        = number
  default     = 60
}

variable "certificate_arn" {
  description = "ACM certificate ARN. When set, the ALB serves HTTPS and redirects HTTP to HTTPS."
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "How long to keep application logs."
  type        = number
  default     = 30
}

variable "deletion_protection" {
  description = "Protect the load balancer from accidental deletion."
  type        = bool
  default     = false
}
