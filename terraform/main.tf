module "network" {
  source = "./modules/network"
  region = var.region
}

module "load_balancing" {
  source            = "./modules/load_balancing"
  public_subnet_ids = module.network.public_subnet_ids
  vpc_id            = module.network.vpc_id
}

module "compute" {
  source                 = "./modules/compute"
  vpc_id                 = module.network.vpc_id
  subnet_ids             = module.network.private_subnet_ids
  allow_traffic_from_sgs = [module.load_balancing.alb_sg_id]
  load_balancer_arn      = module.load_balancing.load_balancer_arn

  # database config
  db_host                = module.database.database_host
  db_port                = module.database.database_port
  db_name                = module.database.database_name
  db_user                = module.database.database_user
  db_password            = module.database.database_password
}

module "database" {
  source     = "./modules/database"
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.private_subnet_ids
  allow_traffic_from_sgs = [module.compute.ecs_sg_id]
}

module "storage" {
  source = "./modules/storage"
}
