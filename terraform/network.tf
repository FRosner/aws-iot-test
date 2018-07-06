data "aws_security_group" "default" {
  id = "${var.security_group_id}"
}

data "aws_vpc" "default" {
  id = "${var.vpc_id}"
}

data "aws_subnet_ids" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
}