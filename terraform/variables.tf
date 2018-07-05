locals {
  project_name = "awsrealtimeseries"
  iot_topic    = "sensors"
}

variable "redis_port" {
  default = "6379"
}
