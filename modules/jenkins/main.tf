resource "aws_instance" "jenkins" {
  ami                    = "ami-0868074ea4024a21c"
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  subnet_id              = var.subnet_id

  tags = {
    Name = "jenkins-master"
  }
}
