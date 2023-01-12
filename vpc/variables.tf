variable "vpc_name" {
  description = "VPC name. Will be used as a 'name' tag"
  type        = string
  default     = "custom vpc"
}

variable "cidr" {
  description = "IPv4 cidr block. Will be used by VPC"
  type        = string
  default     = ""
}

variable "private_subnets" {
  description = "A list of private subnets to be included in VPC"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets to be included in VPC"
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "A list of availability zones for the subnets"
  type        = list(string)
  default     = []
}

variable "private_subnet_tags" {
  description = "A map of tags for the private subnets"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "A map of tags for public subnets"
  type        = map(string)
  default     = {}
}