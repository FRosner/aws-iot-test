variable "kinesis_lambda_version" {
  type    = "string"
  default = "0.1-SNAPSHOT"
}

locals {
  lambda_artifact = "../kinesis-consumer/target/scala-2.12/aws-kinesis-consumer-assembly-${var.kinesis_lambda_version}.jar"
}

resource "aws_lambda_function" "kinesis" {
  function_name    = "${local.project_name}"
  filename         = "${local.lambda_artifact}"
  source_code_hash = "${base64sha256(file(local.lambda_artifact))}"
  handler          = "de.frosner.aws.iot.Handler"
  runtime          = "java8"
  role             = "${aws_iam_role.lambda_exec.arn}"
  memory_size      = 1024
  timeout          = 5

  vpc_config {
    security_group_ids = ["${data.aws_security_group.default.id}"]
    subnet_ids = ["${data.aws_subnet_ids.default.ids[0]}", "${data.aws_subnet_ids.default.ids[1]}"]
  }

  environment {
    variables {
      redis_port = "${aws_elasticache_cluster.sensors.port}"
      redis_url = "${aws_elasticache_cluster.sensors.cache_nodes.0.address}"
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "${local.project_name}-lambda-exec"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy" "AWSLambdaKinesisExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole"
}

data "aws_iam_policy" "AWSLambdaVPCAccessExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_kinesis" {
  role = "${aws_iam_role.lambda_exec.name}"
  policy_arn = "${data.aws_iam_policy.AWSLambdaKinesisExecutionRole.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role = "${aws_iam_role.lambda_exec.name}"
  policy_arn = "${data.aws_iam_policy.AWSLambdaVPCAccessExecutionRole.arn}"
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size        = 10
  event_source_arn  = "${aws_kinesis_stream.sensors.arn}"
  enabled           = true
  function_name     = "${aws_lambda_function.kinesis.id}"
  starting_position = "LATEST"
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "${local.project_name}-lambda-logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${aws_iam_role.lambda_exec.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}
