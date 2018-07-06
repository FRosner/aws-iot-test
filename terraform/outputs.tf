output "iot_topic" {
  value = "topic/${local.iot_topic}"
}

output "redis_address" {
  value = "${aws_elasticache_cluster.sensors.cache_nodes.0.address}:${aws_elasticache_cluster.sensors.port}"
}