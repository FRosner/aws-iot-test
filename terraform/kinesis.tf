resource "aws_kinesis_stream" "sensors" {
  name             = "${local.project_name}"
  shard_count      = 1
  retention_period = 24
}
