output "url" {
  description = "Public URL of the service."
  value       = module.service.url
}

output "cluster_name" {
  description = "ECS cluster name."
  value       = module.service.cluster_name
}

output "service_name" {
  description = "ECS service name."
  value       = module.service.service_name
}

output "log_group_name" {
  description = "CloudWatch log group with the application logs."
  value       = module.service.log_group_name
}
