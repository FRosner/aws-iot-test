resource "aws_elastic_beanstalk_application" "webui" {
  name        = "${local.project_name}"
}

resource "aws_elastic_beanstalk_environment" "webui" {
  name                = "${local.project_name}"
  application         = "${aws_elastic_beanstalk_application.webui.id}"
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.7.1 running Java 8" #https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts.platforms.html#concepts.platforms.javase

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${aws_iam_instance_profile.webui.name}"
  }
}

resource "aws_iam_role" "webui" {
  name = "${local.project_name}-webui"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "aws_iam_policy" "AWSElasticBeanstalkWebTier" {
  arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "webui" {
  role       = "${aws_iam_role.webui.name}"
  policy_arn = "${data.aws_iam_policy.AWSElasticBeanstalkWebTier.arn}"
}

resource "aws_iam_instance_profile" "webui" {
  name = "elb_profile"
  role = "${aws_iam_role.webui.name}"
}

resource "aws_elastic_beanstalk_application_version" "default" {
  name        = "${local.webui_assembly_prefix}"
  application = "${aws_elastic_beanstalk_application.webui.name}"
  description = "application version created by terraform"
  bucket      = "${aws_s3_bucket.webui.id}"
  key         = "${data.aws_s3_bucket_object.application-jar.key}"
}

resource "aws_s3_bucket" "webui" {
  bucket        = "${local.project_name}-webui-artifacts"
  acl           = "private"
  force_destroy = true
}

data "aws_s3_bucket_object" "application-jar" {
  bucket = "${aws_s3_bucket.webui.id}"
  key    = "de/frosner/${local.webui_project_name}_2.12/${var.webui_version}/${local.webui_project_name}_2.12-${var.webui_version}-assembly.jar"
}