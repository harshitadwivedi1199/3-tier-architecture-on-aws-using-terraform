resource "aws_launch_template" "lt" {
  name_prefix   = var.name_prefix
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name = var.key_name
  user_data = var.user_data
  vpc_security_group_ids = var.vpc_security_group_ids
  tags = var.tags_lt
}