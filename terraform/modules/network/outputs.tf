output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets (load balancer, NAT gateway)."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets (application tasks)."
  value       = aws_subnet.private[*].id
}

output "nat_gateway_enabled" {
  description = "Whether private subnets have outbound internet access through NAT."
  value       = var.enable_nat_gateway
}
