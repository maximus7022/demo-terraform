resource "aws_db_subnet_group" "subnet" {
  name       = var.subnet_name
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "rds" {
  identifier             = var.db_identifier
  db_name                = var.db_name
  allocated_storage      = var.storage
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.username
  password               = random_password.password.result
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = true
}
