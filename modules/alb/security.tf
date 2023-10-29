resource "aws_security_group" "demo_lb_sg" {
  name        = "Load Balancer Security Group"
  description = "Allow 80, 443 and 8080 access"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = ["80", "443", "8080"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
