resource "aws_elasticache_cluster" "sensors" {
  cluster_id           = "${local.project_name}"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis4.0"
  port                 = "${var.redis_port}"
}
