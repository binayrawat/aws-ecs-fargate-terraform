output "url" {
  description = "Public URL of the service."
  value       = "${local.https_enabled ? "https" : "http"}://${aws_lb.this.dns_name}"
}

output "alb_dns_name" {
  description = "DNS name of the load balancer (point a CNAME or alias record here)."
  value       = aws_lb.this.dns_name
}

output "cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.app.name
}

output "log_group_name" {
  description = "CloudWatch log group with the application logs."
  value       = aws_cloudwatch_log_group.app.name
}
