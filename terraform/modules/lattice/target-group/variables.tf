variable "name" {
  description = "Name of the target group"
  type        = string
}

variable "type" {
  description = "Type of target group (IP, INSTANCE, ALB, LAMBDA)"
  type        = string
}

variable "config" {
  description = "Target group configuration (required for IP, INSTANCE, and ALB types)"
  type = object({
    port                           = optional(number)
    protocol                       = optional(string)
    vpc_identifier                 = optional(string)
    ip_address_type                = optional(string)
    protocol_version               = optional(string)
    lambda_event_structure_version = optional(string)
    health_check = optional(object({
      enabled                       = optional(bool)
      health_check_interval_seconds = optional(number)
      health_check_timeout_seconds  = optional(number)
      healthy_threshold_count       = optional(number)
      unhealthy_threshold_count     = optional(number)
      matcher                       = optional(string)
      path                          = optional(string)
      port                          = optional(number)
      protocol                      = optional(string)
      protocol_version              = optional(string)
    }))
  })
  default = null
}

variable "targets" {
  description = "Map of targets to attach to the target group"
  type = map(object({
    id   = string
    port = optional(number)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}