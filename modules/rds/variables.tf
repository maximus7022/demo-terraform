variable "host_secret_name" {
  type    = string
  default = "rds-host"
}
variable "database_secret_name" {
  type    = string
  default = "rds-database"
}

variable "username_secret_name" {
  type    = string
  default = "rds-username"
}

variable "password_secret_name" {
  type    = string
  default = "rds-password"
}

variable "subnet_name" {
  type    = string
  default = "rds-subnet-group"
}

variable "subnet_ids" {
  type = list(string)
}

variable "db_name" {
  type = string
}

variable "db_identifier" {
  type = string
}

variable "storage" {
  default = 10
}

variable "username" {
  type    = string
  default = "admin"
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}
