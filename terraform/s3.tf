resource "aws_s3_bucket" "sensor_storage" {
  bucket        = "${local.project_name}-bucket"
  acl           = "private"
  force_destroy = true
}
