variable ingress_rules{
    type = list
}

variable vpc_id{
    type = string
}
variable sg_name{
    type = string
}

variable "egress_rules" {
  type = list(any)
}

variable sg_description{
    type = string
}

variable tags_sg {
  type = map(any) 
}