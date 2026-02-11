variable "name" {
  description = "Name of the VPC Lattice service network"
  type        = string
}

variable "auth_type" {
  description = "Authentication type for the service network (AWS_IAM or NONE)"
  type        = string
  default     = "AWS_IAM"
}

variable "vpc_associations" {
  description = "Map of VPC associations for the service network"
  type = map(object({
    vpc_id             = string
    security_group_ids = list(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}