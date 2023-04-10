variable tags_alb{
    type = map(any)
}
variable security_groups{
    type = list
}
variable name{
    type = string
}
variable subnets{
    type = list
}

variable is_internal{
    type = bool
    default = false
}
    
