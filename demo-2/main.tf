# Copyright IBM Corp. 2023
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.66"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  # count                       = 3 // 👈
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  # vpc_security_group_ids = [aws_security_group.web.id] // 👈
  # subnet_id                   = aws_subnet.public[count.index].id // 👈
  associate_public_ip_address = true
  # tags = {
  #   "Index" = count.index // 👈
  # }

  # user_data = templatefile("user-data.sh.tftpl", { // 👈
  #   index = count.index
  # })
}

resource "aws_security_group" "web" {
  name   = "web"
  vpc_id = aws_vpc.default.id
}

resource "aws_security_group_rule" "web_egress_out" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.web.id
  type              = "egress"
}
