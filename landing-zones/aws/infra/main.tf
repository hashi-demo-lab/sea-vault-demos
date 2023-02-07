provider "aws" {
  region = var.region
}

resource "aws_vpc" "future" {
  cidr_block           = var.address_space
  enable_dns_hostnames = true

  tags = {
    name        = "${var.prefix}-vpc-${var.region}"
    environment = "Production"
  }
}

resource "aws_subnet" "future" {
  vpc_id     = aws_vpc.future.id
  cidr_block = var.subnet_prefix

  tags = {
    name = "${var.prefix}-subnet"
  }
}

resource "aws_security_group" "future" {
  name = "${var.prefix}-security-group"

  vpc_id = aws_vpc.future.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.prefix}-security-group"
  }
}

resource "aws_internet_gateway" "future" {
  vpc_id = aws_vpc.future.id

  tags = {
    Name = "${var.prefix}-internet-gateway"
  }
}

resource "aws_route_table" "future" {
  vpc_id = aws_vpc.future.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.future.id
  }
}

resource "aws_route_table_association" "future" {
  subnet_id      = aws_subnet.future.id
  route_table_id = aws_route_table.future.id
}