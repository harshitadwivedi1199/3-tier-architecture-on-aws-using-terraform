resource "aws_nat_gateway" "my_nat" {
  subnet_id     =  var.nat_subnet_id  #aws_subnet.my_public_subnet1.id
  allocation_id = var.eip_id
  tags = var.tags_nat
  
}