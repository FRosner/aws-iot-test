resource "aws_iot_topic_rule" "rule" {
  name        = "${local.project_name}Kinesis"
  description = "Kinesis Rule"
  enabled     = true
  sql         = "SELECT * FROM 'topic/${local.iot_topic}'"
  sql_version = "2015-10-08"

  kinesis {
    role_arn    = "${aws_iam_role.iot.arn}"
    stream_name = "${aws_kinesis_stream.sensors.id}"
  }
}

resource "aws_iam_role" "iot" {
  name = "${local.project_name}-iot-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "iot.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iot_kinesis" {
  name = "${local.project_name}-iot-kinesis-policy"
  role = "${aws_iam_role.iot.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:PutRecord"
      ],
      "Resource": [
        "${aws_kinesis_stream.sensors.arn}"
      ]
    }
  ]
}
EOF
}