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

//resource "aws_sns_topic_subscription" "lambda" {
//  topic_arn = "${aws_sns_topic.upload.arn}"
//  protocol  = "lambda"
//  endpoint  = "${aws_lambda_function.slack.arn}"
//}

//resource "aws_lambda_permission" "sns" {
//  statement_id  = "AllowExecutionFromSNS"
//  action        = "lambda:InvokeFunction"
//  function_name = "${aws_lambda_function.slack.function_name}"
//  principal     = "sns.amazonaws.com"
//  source_arn = "${aws_sns_topic.upload.arn}"
//}

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
