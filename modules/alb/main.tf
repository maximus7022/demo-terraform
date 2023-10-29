data "aws_instance" "jenkins_ec2" {
  filter {
    name   = "tag:Name"
    values = ["jenkins-master"]
  }
}

resource "aws_lb" "lb" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.demo_lb_sg.id]
  subnets            = var.subnets
}

resource "aws_lb_target_group" "jenkins_tg" {
  name     = var.tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "jenkins_tg" {
  target_group_arn = aws_lb_target_group.jenkins_tg.arn
  target_id        = data.aws_instance.jenkins_ec2.id
  port             = 80
}

resource "aws_lb_listener" "jenkins_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
