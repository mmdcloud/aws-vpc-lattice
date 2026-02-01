# Output the DNS names for testing
output "service1_dns" {
  value = aws_vpclattice_service.service1.dns_entry[0].domain_name
}

output "service2_dns" {
  value = aws_vpclattice_service.service2.dns_entry[0].domain_name
}