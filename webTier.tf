#subnet for web layer
module "subnet-pub-1a" {
  source      = "./modules/subnet"
  vpc_id      = module.my_vpc.my_vpc_id
  cidr_subnet = var.cidr_subnet_1
  az_subnet   = var.az_subnet_1
  public      = var.public_1
  tags_subnet = var.tags_subnet_1

}

# output "subnet-pub-1a-id" {
#   value = module.subnet-pub-1a.subnet_id
# }

module "subnet-pub-1b" {
  source      = "./modules/subnet"
  vpc_id      = module.my_vpc.my_vpc_id
  cidr_subnet = var.cidr_subnet_2
  az_subnet   = var.az_subnet_2
  public      = var.public_2
  tags_subnet = var.tags_subnet_2

}

# output "subnet-pub-1b-id" {
#   value = module.subnet-pub-1b.subnet_id
# }

# route table association
module "rt_ass_pub_1a" {
  source         = "./modules/rt_association"
  subnet_id      = module.subnet-pub-1a.subnet_id
  route_table_id = module.public_rt.rt_id
}

module "rt_ass_pub_1b" {
  source         = "./modules/rt_association"
  subnet_id      = module.subnet-pub-1b.subnet_id
  route_table_id = module.public_rt.rt_id
}

#Security Group

module "sg_alb_web" {
  source         = "./modules/security_group"
  ingress_rules  = var.ingress_rules_web
  vpc_id         = module.my_vpc.my_vpc_id
  sg_name        = var.sg_name_web
  sg_description = var.sg_description_web
  egress_rules   = var.egress_rules_web
  #security_groups = var.security_groups_web
  tags_sg = var.tags_sg_web
}

# output "sg_alb_web_id" {
#   value = module.sg_alb_web.sg_id
# }


#Application load balancer 

module "web-alb" {
  source = "./modules/application_load_balancer"
  name   = "tf-webtier-alb"
  #internal           = false
  #load_balancer_type = "application"
  security_groups = [module.sg_alb_web.sg_id]
  subnets         = [module.subnet-pub-1a.subnet_id, module.subnet-pub-1b.subnet_id]

  #enable_deletion_protection = false

  tags_alb = var.tags_alb_web
}

# output "web-alb_arn" {
#   value = module.web-alb.alb_arn
# }

#Target group
module "webTier-tg" {
  source   = "./modules/target_group"
  name     = "tf-webTier-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.my_vpc.my_vpc_id
  tags_tg  = var.tags_web_tg
}

# output "webTier-tg-arn" {
#   value = module.webTier-tg.tg_arn
# }

#Listener group

module "http_listener_web" {
  source   = "./modules/listener_group"
  lb_arn   = module.web-alb.alb_arn
  port     = "80"
  protocol = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  tg_arn = module.webTier-tg.tg_arn
}

#autoscaling
module "web_asg1" {
  source              = "./modules/autoscaling_group"
  vpc_zone_identifier = [module.subnet-pub-1a.subnet_id]
  #  availability_zones = ["ap-south-1a"]
  desired_capacity  = 1
  max_size          = 1
  min_size          = 1
  target_group_arns = [module.webTier-tg.tg_arn]
  launch_template   = module.webtier_lt.lt_id

}

module "web_asg2" {
  source              = "./modules/autoscaling_group"
  vpc_zone_identifier = [module.subnet-pub-1b.subnet_id]
  #  availability_zones = ["ap-south-1a"]
  desired_capacity  = 1
  max_size          = 1
  min_size          = 1
  target_group_arns = [module.webTier-tg.tg_arn]
  launch_template   = module.webtier_lt.lt_id

}


# security group for webserver

module "sg_web_server" {
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
  ] #var.ingress_rules_web_server
  vpc_id         = module.my_vpc.my_vpc_id
  sg_name        = var.sg_name_web_server
  sg_description = var.sg_description_web_server
  egress_rules   = var.egress_rules_web_server
  #security_groups = var.security_groups_web_server
  tags_sg = var.tags_sg_web_server
}


# launch template

module "webtier_lt" {
  source                 = "./modules/launch_template"
  name_prefix            = "tf-webserver-"
  image_id               = "ami-093613b5938a7e47c"
  instance_type          = "t2.micro"
  key_name               = "tf-keypair"
  user_data              = filebase64("${path.module}/web.sh")
  vpc_security_group_ids = [module.sg_web_server.sg_id]
  tags_lt = {
    Name = "tf-webtier_lt",
    Kind = "practice"
  }
}

# output "webtier_lt-id" {
#   value = module.webtier_lt.lt_id
# }

