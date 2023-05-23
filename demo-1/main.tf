terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.66"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.3"
    }
  }
}

provider "aws" {
  region = "eu-west-2" // us-east-1
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

variable "key_name" {
  type = string
}

data "aws_key_pair" "admin" {
  key_name = var.key_name
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = data.aws_key_pair.admin.key_name
  vpc_security_group_ids = [aws_security_group.web.id] // TODO: find out why .id doesn't bring up right candidates
  // vpc_security_group_ids = [ aws_security_group.web.id ] // 👈 1️⃣

  provisioner "remote-exec" {
    connection {
      host = self.public_ip
      user = "ubuntu"
    }

    inline = var.commands
  }

  # provisioner "remote-exec" { // 👈 2️⃣
  #   connection {
  #     host = self.public_ip // 👈 3️⃣
  #     user = "ubuntu"
  #   }
  #   # inline = [  // 👈 4️⃣
  #   #   "sudo apt update -y",
  #   #   "sudo apt install -y nginx",
  #   #   "sudo sh -c 'echo \"Hello from the other side</strong>\" > /var/www/html/index.html'",
  #   #   "sudo systemctl reload nginx",
  #   # ]
  #   inline = var.commands // 👈 5️⃣
  # }
}

data "http" "ip" {
  url = "https://ipinfo.io/ip"
}

resource "aws_security_group" "web" {
  name = "web"
}

resource "aws_security_group_rule" "web_ssh_in" {
  cidr_blocks       = ["${sensitive(data.http.ip.response_body)}/32"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.web.id
  type              = "ingress"
}

resource "aws_security_group_rule" "web_http_in" {
  cidr_blocks       = ["${sensitive(data.http.ip.response_body)}/32"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.web.id
  type              = "ingress"
}

resource "aws_security_group_rule" "web_egress_out" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.web.id
  type              = "egress"
}

output "public_web_ip" {
  value = "http://${aws_instance.web.public_ip}"
}
