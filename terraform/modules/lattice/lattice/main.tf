resource "aws_vpclattice_service" "this" {
  name            = var.name
  auth_type       = var.auth_type
  certificate_arn = var.certificate_arn

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_vpclattice_listener" "this" {
  for_each = var.listeners

  service_identifier = aws_vpclattice_service.this.id
  name               = each.value.name
  port               = each.value.port
  protocol           = each.value.protocol

  default_action {
    dynamic "forward" {
      for_each = lookup(each.value, "forward", null) != null ? [each.value.forward] : []
      content {
        dynamic "target_groups" {
          for_each = forward.value.target_groups
          content {
            target_group_identifier = target_groups.value.target_group_identifier
            weight                  = lookup(target_groups.value, "weight", 100)
          }
        }
      }
    }

    dynamic "fixed_response" {
      for_each = lookup(each.value, "fixed_response", null) != null ? [each.value.fixed_response] : []
      content {
        status_code = fixed_response.value.status_code
      }
    }
  }

  tags = merge(var.tags, { Name = "${var.name}-${each.key}" })
}

resource "aws_vpclattice_service_network_service_association" "this" {
  for_each = var.service_network_associations

  service_identifier         = aws_vpclattice_service.this.id
  service_network_identifier = each.value.service_network_id

  tags = merge(var.tags, { Name = "${var.name}-${each.key}" })
}