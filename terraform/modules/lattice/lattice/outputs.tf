output "service_id" {
  description = "ID of the VPC Lattice service"
  value       = aws_vpclattice_service.this.id
}

output "service_arn" {
  description = "ARN of the VPC Lattice service"
  value       = aws_vpclattice_service.this.arn
}

output "service_dns_entry" {
  description = "DNS entry for the service"
  value       = aws_vpclattice_service.this.dns_entry
}

output "listener_ids" {
  description = "Map of listener IDs"
  value       = { for k, v in aws_vpclattice_listener.this : k => v.id }
}

output "service_network_association_ids" {
  description = "Map of service network association IDs"
  value       = { for k, v in aws_vpclattice_service_network_service_association.this : k => v.id }
}