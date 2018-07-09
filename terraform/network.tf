resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_security_group" "all_out" {
  vpc_id      = "${aws_vpc.main.id}"
  name        = "${local.project_name}-all_out"
  description = "Elastic Beanstalk Terraform Security Group"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "all" {
  vpc_id      = "${aws_vpc.main.id}"
  name        = "${local.project_name}-all"
  description = "Elastic Beanstalk Terraform Security Group"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
}

resource "aws_subnet" "public-1" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-central-1a"
}

resource "aws_subnet" "public-2" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "eu-central-1b"
}

resource "aws_subnet" "public-3" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "eu-central-1c"
}

resource "aws_subnet" "private-1" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = "eu-central-1a"
}

resource "aws_subnet" "private-2" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.0.5.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = "eu-central-1b"
}

resource "aws_subnet" "private-3" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "10.0.6.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = "eu-central-1c"
}

resource "aws_route_table_association" "public-1-a" {
  subnet_id = "${aws_subnet.public-1.id}"
  route_table_id = "${aws_route_table.public.id}"
}
resource "aws_route_table_association" "public-2-a" {
  subnet_id = "${aws_subnet.public-2.id}"
  route_table_id = "${aws_route_table.public.id}"
}
resource "aws_route_table_association" "public-3-a" {
  subnet_id = "${aws_subnet.public-3.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "main" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public-1.id}"
  depends_on    = ["aws_internet_gateway.main"]
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.main.id}"
  }
}

resource "aws_route_table_association" "main-private-1-a" {
  subnet_id = "${aws_subnet.private-1.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "main-private-2-a" {
  subnet_id = "${aws_subnet.private-2.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "main-private-3-a" {
  subnet_id = "${aws_subnet.private-3.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_elasticache_subnet_group" "private" {
  name       = "${local.project_name}"
  subnet_ids = ["${aws_subnet.private-1.id}", "${aws_subnet.private-2.id}", "${aws_subnet.private-3.id}"]
}