resource "aws_db_subnet_group" "subnet_group" {
  name       = var.subnet_group_name
  subnet_ids = var.subnet_ids_subnet_group

  tags = var.tags_subnet_group
}