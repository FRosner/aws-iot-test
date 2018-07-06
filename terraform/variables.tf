locals {
  project_name = "awsrealtimeseries"
  iot_topic    = "sensors"
  lambda_artifact = "../kinesis-consumer/target/scala-2.12/aws-kinesis-consumer-assembly-${var.kinesis_lambda_version}.jar"
  webui_project_name = "aws-realtime-webui"
  webui_assembly_prefix = "${local.webui_project_name}-assembly-${var.webui_version}"
  webui_assembly_jar = "${local.webui_assembly_prefix}.jar"
}

variable "redis_port" {
  default = "6379"
}

variable "webui_version" {
  type = "string"
  default = "0.1-SNAPSHOT"
}

variable "kinesis_lambda_version" {
  type    = "string"
  default = "0.1-SNAPSHOT"
}

variable "security_group_id" {}

variable "vpc_id" {}

variable "subnet_id" {}

