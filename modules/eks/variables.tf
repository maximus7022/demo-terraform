variable "tags" {}

variable "env" {}

variable "cluster_name" {}

variable "vpc_id" {}

variable "vpc_cidr" {}

variable "subnet_ids" {}

locals {
  eks_subnets_private_tags = tomap({
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  })
  eks_subnets_public_tags = tomap({
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  })
}
