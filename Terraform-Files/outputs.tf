output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.medusa.dns_name
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.medusa.name
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.medusa.endpoint
}

output "redis_endpoint" {
  description = "The endpoint of the Redis cluster"
  value       = aws_elasticache_cluster.medusa.cache_nodes[0].address
}
output "ecr_repository_url" {
  value = aws_ecr_repository.medusa.repository_url
}

