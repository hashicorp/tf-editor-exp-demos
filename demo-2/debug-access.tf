# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Uncomment the following and add key_name to aws_instance
# in case you need to SSH and debug things.

# variable "key_name" {
#   type = string
# }

# data "aws_key_pair" "admin" {
#   key_name = var.key_name
# }

# output "instance_ips" {
#   value = aws_instance.web[*].public_ip
# }

# data "http" "ip" {
#   url = "https://ipinfo.io/ip"
# }

# resource "aws_security_group_rule" "web_ssh_in" {
#   cidr_blocks       = ["${sensitive(data.http.ip.response_body)}/32"]
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"
#   security_group_id = aws_security_group.web.id
#   type              = "ingress"
# }
