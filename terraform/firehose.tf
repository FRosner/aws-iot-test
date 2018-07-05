resource "aws_kinesis_firehose_delivery_stream" "sensors" {
  name        = "${local.project_name}-s3"
  destination = "s3"

  s3_configuration {
    role_arn        = "${aws_iam_role.firehose.arn}"
    bucket_arn      = "${aws_s3_bucket.sensor_storage.arn}"
    buffer_size     = 5
    buffer_interval = 60
  }
}

resource "aws_iam_role" "firehose" {
  name = "${local.project_name}-firehose"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "firehose_s3_kinesis" {
  name        = "${local.project_name}-firehose-s3-kinesis"
  path        = "/"
  description = "Allow Firehose to write to S3"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Resource": [
                "${aws_s3_bucket.sensor_storage.arn}",
                "${aws_s3_bucket.sensor_storage.arn}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:GetShardIterator",
                "kinesis:GetRecords"
            ],
            "Resource": "${aws_kinesis_stream.sensors.arn}"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "firehose_s3_kinesis" {
  role       = "${aws_iam_role.firehose.name}"
  policy_arn = "${aws_iam_policy.firehose_s3_kinesis.arn}"
}
