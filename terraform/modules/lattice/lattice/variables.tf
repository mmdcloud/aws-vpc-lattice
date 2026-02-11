variable "name" {
  description = "Name of the VPC Lattice service"
  type        = string
}

variable "auth_type" {
  description = "Authentication type for the service (AWS_IAM or NONE)"
  type        = string
  default     = "AWS_IAM"
}

variable "certificate_arn" {
  description = "ARN of the certificate for HTTPS listeners"
  type        = string
  default     = null
}

variable "listeners" {
  description = "Map of listeners for the service"
  type = map(object({
    name     = string
    port     = number
    protocol = string
    forward = optional(object({
      target_groups = list(object({
        target_group_identifier = string
        weight                  = optional(number, 100)
      }))
    }))
    fixed_response = optional(object({
      status_code = number
    }))
  }))
  default = {}
}

variable "service_network_associations" {
  description = "Map of service network associations"
  type = map(object({
    service_network_id = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}