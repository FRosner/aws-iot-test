locals {
  project_name = "awsrealtimeseries"
  iot_topic    = "sensors"
}

variable "redis_port" {
  default = "6379"
}

variable "security_group_id" {}

variable "vpc_id" {}

variable "subnet_id" {}
