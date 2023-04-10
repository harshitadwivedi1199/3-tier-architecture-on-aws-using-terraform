variable vpc_id {
    type=string
}

variable "cidr_subnet" {
  type = string
}

variable "az_subnet" {
  type = string
}

variable "tags_subnet" {
  type = map(any)
}

variable "public" {
  type = bool
}