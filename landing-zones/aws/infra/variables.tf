variable "region" {
  type        = string
  description = "The region where the resources are created."
  default     = "ap-southeast-2"
}

variable "prefix" {
  type        = string
  description = "This prefix will be included in the name of most resources."
  default     = "future"
}

variable "address_space" {
  type        = string
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  type        = string
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}