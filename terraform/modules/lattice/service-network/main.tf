resource "aws_vpclattice_service_network" "this" {
  name      = var.name
  auth_type = var.auth_type
  tags      = merge(var.tags, { Name = var.name })
}

resource "aws_vpclattice_service_network_vpc_association" "this" {
  for_each = var.vpc_associations

  service_network_identifier = aws_vpclattice_service_network.this.id
  vpc_identifier             = each.value.vpc_id
  security_group_ids         = each.value.security_group_ids

  tags = merge(var.tags, { Name = "${var.name}-${each.key}" })
}