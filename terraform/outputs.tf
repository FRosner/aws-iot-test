output "iot_topic" {
  value = "topic/${local.iot_topic}"
}

output "redis_address" {
  value = "${aws_elasticache_cluster.sensors.cache_nodes.0.address}:${aws_elasticache_cluster.sensors.port}"
}

output "aws_command" {
  value = "aws elasticbeanstalk update-environment --application-name ${aws_elastic_beanstalk_application.webui.name} --version-label ${aws_elastic_beanstalk_application_version.default.name} --environment-name ${aws_elastic_beanstalk_environment.webui.name}"
}

output "webui_artifact_bucket" {
  value = "${aws_s3_bucket.webui.bucket_domain_name}"
}