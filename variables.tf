variable "env" {
  type    = string
  default = "dev"
}

variable "app_name" {
  default = "laravel"
}

locals {
  tags = {
    Environment = var.env
  }
}

# ===================NETWORK=======================

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  type = list(string)
  default = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}

# ===================ECR=======================

variable "repository_name" {
  type    = string
  default = "laravel-app-ecr-repo"
}

# ===================ALB=======================

variable "lb_name" {
  type    = string
  default = "jenkins-demo-lb"
}

variable "tg_name" {
  type    = string
  default = "jenkins-tg"
}

variable "domain" {
  type    = string
  default = "max-pash.pp.ua"
}

# ===================RDS=======================

locals {
  db_name       = format("%sDB", var.app_name)
  db_identifier = "${var.app_name}-${var.env}-db"
}

# ===================EKS=======================

variable "cluster_name" {
  type    = string
  default = "demo-cluster"
}
