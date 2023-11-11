resource "aws_security_group" "jenkins_sg" {
  name        = "Jenkins Security Group"
  description = "Allow 80 access"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = ["80"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
