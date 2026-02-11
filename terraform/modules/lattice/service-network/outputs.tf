output "service_network_id" {
  description = "ID of the VPC Lattice service network"
  value       = aws_vpclattice_service_network.this.id
}

output "service_network_arn" {
  description = "ARN of the VPC Lattice service network"
  value       = aws_vpclattice_service_network.this.arn
}

output "vpc_association_ids" {
  description = "Map of VPC association IDs"
  value       = { for k, v in aws_vpclattice_service_network_vpc_association.this : k => v.id }
}