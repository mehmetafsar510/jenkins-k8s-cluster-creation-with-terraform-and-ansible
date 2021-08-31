module "iam" {
  source = "./modules/IAM"
}

module "network" {
  source         = "./modules/Network"
  vpc_cidr_block = var.vpc_cidr
  public_sn_count            = 2
  private_sn_count           = 2
  max_subnets                = 20
  public_cidrs               = [for i in range(10, 255, 10) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_cidrs              = [for i in range(11, 255, 10) : cidrsubnet(var.vpc_cidr, 8, i)]
}

module "compute" {
  source = "./modules/Compute"
  vpc_id = module.network.vpc_id
  public_subnets = module.network.public_subnet[0]
  master_profile_name = module.iam.master_profile_name
  worker_profile_name = module.iam.worker_profile_name
  key_name       = var.key_name
}

