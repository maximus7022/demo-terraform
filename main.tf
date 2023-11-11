module "network" {
  source               = "./modules/network"
  env                  = var.env
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  cluster_name         = var.cluster_name
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.repository_name
}

module "jenkins" {
  source    = "./modules/jenkins"
  vpc_id    = module.network.vpc_id
  vpc_cidr  = var.vpc_cidr
  subnet_id = module.network.private_subnet_ids[0]

  depends_on = [module.network]
}

module "alb" {
  source  = "./modules/alb"
  vpc_id  = module.network.vpc_id
  lb_name = var.lb_name
  tg_name = var.tg_name
  subnets = module.network.public_subnet_ids
  domain  = var.domain

  depends_on = [module.jenkins]
}

module "rds" {
  source        = "./modules/rds"
  db_name       = local.db_name
  db_identifier = local.db_identifier
  vpc_id        = module.network.vpc_id
  vpc_cidr      = var.vpc_cidr
  subnet_ids    = module.network.private_subnet_ids
}

module "eks" {
  source       = "./modules/eks"
  env          = var.env
  tags         = local.tags
  vpc_id       = module.network.vpc_id
  vpc_cidr     = var.vpc_cidr
  cluster_name = var.cluster_name
  subnet_ids   = module.network.private_subnet_ids

  depends_on = [module.network]
}

module "app" {
  source          = "./modules/app"
  domain          = var.domain
  certificate_arn = module.alb.certificate_arn
  ecr_repository  = module.ecr.ecr_repository_url
  depend          = module.rds

  depends_on = [module.eks]
}

module "monitoring" {
  source          = "./modules/monitoring"
  domain          = var.domain
  certificate_arn = module.alb.certificate_arn

  depends_on = [module.app]
}
