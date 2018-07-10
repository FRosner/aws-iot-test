resource "aws_elastic_beanstalk_application" "webui" {
  name = "${local.project_name}"
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

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "redis_url"
    value     = "${aws_elasticache_cluster.sensors.cache_nodes.0.address}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "redis_port"
    value     = "${aws_elasticache_cluster.sensors.port}"
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "LoadBalancerPortProtocol"
    value     = "TCP"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${aws_vpc.main.id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${aws_subnet.private-1.id},${aws_subnet.private-2.id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "false"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = "${aws_security_group.all_out.id}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "public"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = "${aws_subnet.public-1.id},${aws_subnet.public-2.id}"
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "CrossZone"
    value     = "true"
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
