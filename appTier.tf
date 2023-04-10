#subnet for app layer
module "subnet-priv-1a" {
  source      = "./modules/subnet"
  vpc_id      = module.my_vpc.my_vpc_id
  cidr_subnet = var.cidr_subnet_3
  az_subnet   = var.az_subnet_3
  public      = var.public_3
  tags_subnet = var.tags_subnet_3

}

# output "subnet-priv-1a-id" {
#   value = module.subnet-priv-1a.subnet_id
# }

module "subnet-priv-1b" {
  source      = "./modules/subnet"
  vpc_id      = module.my_vpc.my_vpc_id
  cidr_subnet = var.cidr_subnet_4
  az_subnet   = var.az_subnet_4
  public      = var.public_4
  tags_subnet = var.tags_subnet_4

}

# output "subnet-priv-1b-id" {
#   value = module.subnet-priv-1b.subnet_id
# }

# route table association 
module "rt_ass_priv_1a" {
  source         = "./modules/rt_association"
  subnet_id      = module.subnet-priv-1a.subnet_id
  route_table_id = module.private_rt.rt_id
}

module "rt_ass_priv_1b" {
  source         = "./modules/rt_association"
  subnet_id      = module.subnet-priv-1b.subnet_id
  route_table_id = module.private_rt.rt_id
}

#security group

module "sg_alb_app" {
  source         = "./modules/security_group"
  ingress_rules  = var.ingress_rules_app
  vpc_id         = module.my_vpc.my_vpc_id
  sg_name        = var.sg_name_app
  sg_description = var.sg_description_app
  egress_rules   = var.egress_rules_app
  #security_groups = var.security_groups_app
  tags_sg = var.tags_sg_app
}
# output "sg_alb_app_id" {
#   value = module.sg_alb_app.sg_id
# }



#Application load balancer 
module "app-alb" {
  source = "./modules/application_load_balancer"
  name   = "tf-apptier-alb"
  #internal           = false
  #load_balancer_type = "application"
  security_groups = [module.sg_alb_app.sg_id]
  subnets         = [module.subnet-priv-1a.subnet_id, module.subnet-priv-1b.subnet_id]
  is_internal     = true
  #enable_deletion_protection = false

  tags_alb = var.tags_alb_app
}

# output "app-alb_arn" {
#   value = module.app-alb.alb_arn
# }

#Target Group
module "appTier-tg" {
  source   = "./modules/target_group"
  name     = "tf-appTier-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.my_vpc.my_vpc_id
  tags_tg  = var.tags_app_tg
}

# output "appTier-tg-arn" {
#   value = module.appTier-tg.tg_arn
# }

#Listener group 
module "http_listener_app" {
  source   = "./modules/listener_group"
  lb_arn   = module.app-alb.alb_arn
  port     = "80"
  protocol = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  tg_arn = module.appTier-tg.tg_arn
}

#autoscaling
module "app_asg1" {
  source              = "./modules/autoscaling_group"
  vpc_zone_identifier = [module.subnet-priv-1a.subnet_id]
  #  availability_zones = ["ap-south-1a"]
  desired_capacity  = 1
  max_size          = 1
  min_size          = 1
  target_group_arns = [module.appTier-tg.tg_arn]
  launch_template   = module.apptier_lt.lt_id


}

module "app_asg2" {
  source              = "./modules/autoscaling_group"
  vpc_zone_identifier = [module.subnet-priv-1b.subnet_id]
  #  availability_zones = ["ap-south-1a"]
  desired_capacity  = 1
  max_size          = 1
  min_size          = 1
  target_group_arns = [module.appTier-tg.tg_arn]
  launch_template   = module.apptier_lt.lt_id


}

#security group for app server

module "sg_app_server" {
  source = "./modules/security_group"
  ingress_rules = [
    {
      description     = "allow on 443"
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      cidr_blocks     = null
      security_groups = [module.sg_alb_web.sg_id]
    },
    {
      description     = "allow on 80"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks     = null
      security_groups = [module.sg_alb_web.sg_id]
    }

  ] #var.ingress_rules_app_server
  vpc_id         = module.my_vpc.my_vpc_id
  sg_name        = var.sg_name_app_server
  sg_description = var.sg_description_app_server
  egress_rules   = var.egress_rules_app_server
  #security_groups = var.security_groups_app_server
  tags_sg = var.tags_sg_app_server
}

#Launch template
module "apptier_lt" {
  source                 = "./modules/launch_template"
  name_prefix            = "tf-appserver-"
  image_id               = "ami-093613b5938a7e47c"
  instance_type          = "t2.micro"
  key_name               = "tf-keypair"
  user_data              = filebase64("${path.module}/app.sh")
  vpc_security_group_ids = [module.sg_app_server.sg_id]
  tags_lt = {
    Name = "tf-webtier_lt",
    Kind = "practice"
  }
}

# output "apptier_lt-id" {
#   value = module.apptier_lt.lt_id
# }

#To add ingress rule in app server security group

resource "aws_security_group_rule" "rds_connection" {
  depends_on = [
    module.sg_rds
  ]
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.sg_rds.sg_id
  security_group_id = module.sg_app_server.sg_id
}