resource "aws_vpclattice_target_group" "this" {
  name = var.name
  type = var.type

  dynamic "config" {
    for_each = var.config != null ? [var.config] : []
    content {
      port                  = config.value.port
      protocol              = config.value.protocol
      vpc_identifier        = config.value.vpc_identifier
      ip_address_type       = lookup(config.value, "ip_address_type", null)
      protocol_version      = lookup(config.value, "protocol_version", null)
      lambda_event_structure_version = lookup(config.value, "lambda_event_structure_version", null)

      dynamic "health_check" {
        for_each = lookup(config.value, "health_check", null) != null ? [config.value.health_check] : []
        content {
          enabled                       = lookup(health_check.value, "enabled", true)
          health_check_interval_seconds = lookup(health_check.value, "health_check_interval_seconds", null)
          health_check_timeout_seconds  = lookup(health_check.value, "health_check_timeout_seconds", null)
          healthy_threshold_count       = lookup(health_check.value, "healthy_threshold_count", null)
          unhealthy_threshold_count     = lookup(health_check.value, "unhealthy_threshold_count", null)
          path                          = lookup(health_check.value, "path", null)
          port                          = lookup(health_check.value, "port", null)
          protocol                      = lookup(health_check.value, "protocol", null)
          protocol_version              = lookup(health_check.value, "protocol_version", null)
        }
      }
    }
  }

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_vpclattice_target_group_attachment" "this" {
  for_each = var.targets

  target_group_identifier = aws_vpclattice_target_group.this.id

  target {
    id   = each.value.id
    port = lookup(each.value, "port", null)
  }
}