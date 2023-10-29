terraform {
  required_version = ">= 1.2.0"

  backend "s3" {
    bucket         = "tf-rmt-state-s3-bucket"
    key            = "terraform/eks-test/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "dydb-terraform-state-lock"
    session_name   = "terraform"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

provider "kubernetes" {
  host                   = module.eks.eks_endpoint
  cluster_ca_certificate = base64decode(module.eks.eks_certificate_authority)
  token                  = module.eks.eks_auth_token
}

provider "kubectl" {
  host                   = module.eks.eks_endpoint
  cluster_ca_certificate = base64decode(module.eks.eks_certificate_authority)
  token                  = module.eks.eks_auth_token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = module.eks.eks_endpoint
    cluster_ca_certificate = base64decode(module.eks.eks_certificate_authority)
    token                  = module.eks.eks_auth_token
  }
}
