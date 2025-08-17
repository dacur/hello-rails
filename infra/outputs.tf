output "repository_url" {
  description = "ECR repo URL"
  value       = aws_ecr_repository.repo.repository_url
}

output "cluster_name" {
  value = aws_ecs_cluster.app.name
}

output "service_name" {
  value = aws_ecs_service.app.name
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}
