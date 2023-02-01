variable "region" {
  type = string
  description = "The region where the resources are created"
  nullable = false
}

variable "prefix" {
  type = string
  description = "This prefix will be included in the name of most resources"
  nullable = false
}

variable "vpc_cidr_block" {
  type = string
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  nullable = false
}

variable "subnet_cidr_block" {
  type = string
  description = "The address space to use for the subnet"
  nullable = false
}