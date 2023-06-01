# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "aws_lb" "default" {
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.lb.id]
}

resource "aws_security_group" "lb" {
  name   = "lb"
  vpc_id = aws_vpc.default.id
}

resource "aws_security_group_rule" "lb_http_in" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.lb.id
  type              = "ingress"
}

resource "aws_security_group_rule" "web_http_in" {
  source_security_group_id = aws_security_group.lb.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.web.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "lb_egress_out" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.lb.id
  type              = "egress"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.default.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}

output "public_lb_dns" {
  value = "http://${aws_lb.default.dns_name}"
}

resource "aws_lb_target_group" "default" {
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.default.id
}

resource "aws_lb_target_group_attachment" "instances" {
  count            = length(aws_instance.web[*])
  target_group_arn = aws_lb_target_group.default.arn
  target_id        = aws_instance.web[count.index].id
}
