variable "name" {
  description = "Name prefix for all network resources."
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC. Subnets are carved out as /24s."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to spread subnets across."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3 (an ALB needs at least two AZs)."
  }
}

variable "enable_nat_gateway" {
  description = "Create a single NAT gateway so private subnets can reach the internet (ECR, CloudWatch). Costs about $35/month."
  type        = bool
  default     = true
}

variable "flow_log_retention_days" {
  description = "How long to keep VPC flow logs."
  type        = number
  default     = 14
}
