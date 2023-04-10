output "vpc_id" {
  value = module.my_vpc.my_vpc_id
}

output "igw_id" {
  value = module.igw.my_igw_id
}

output "eip_id" {
  value = module.eip.eip_id
}

output "nat_id" {
  value = module.nat.nat_id
}

output "public_rt_id" {
  value = module.public_rt.rt_id
}

output "private_rt_id" {
  value = module.private_rt.rt_id
}

##Web tier
output "subnet-pub-1a-id" {
  value = module.subnet-pub-1a.subnet_id
}

output "subnet-pub-1b-id" {
  value = module.subnet-pub-1b.subnet_id
}

output "sg_alb_web_id" {
  value = module.sg_alb_web.sg_id
}

output "web-alb_arn" {
  value = module.web-alb.alb_arn
}

output "webTier-tg-arn" {
  value = module.webTier-tg.tg_arn
}

output "webtier_lt-id" {
  value = module.webtier_lt.lt_id
}

##App Tier 

output "subnet-priv-1a-id" {
  value = module.subnet-priv-1a.subnet_id
}

output "subnet-priv-1b-id" {
  value = module.subnet-priv-1b.subnet_id
}

output "sg_alb_app_id" {
  value = module.sg_alb_app.sg_id
}

output "app-alb_arn" {
  value = module.app-alb.alb_arn
}

output "appTier-tg-arn" {
  value = module.appTier-tg.tg_arn
}

output "apptier_lt-id" {
  value = module.apptier_lt.lt_id
}

##Data Tier

output "subnet-rds-priv-1a-id" {
  value = module.subnet-rds-priv-1a.subnet_id
}

output "subnet-rds-priv-1b-id" {
  value = module.subnet-rds-priv-1b.subnet_id
}

output "sg_rds_id" {
  value = module.sg_rds.sg_id
}

output subnet_group_id {
  value = module.db_subnet_group.subnet_group_id
}

