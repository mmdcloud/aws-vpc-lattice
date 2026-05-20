# # Output the DNS names for testing
# output "service1_dns" {
#   value = aws_vpclattice_service.service1.dns_entry[0].domain_name
# }

# output "service2_dns" {
#   value = aws_vpclattice_service.service2.dns_entry[0].domain_name
# }

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.eks.endpoint
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.eks.name
}

output "eks_cluster_certificate_authority" {
  description = "Base64 CA cert for kubeconfig"
  value       = aws_eks_cluster.eks.certificate_authority[0].data
  sensitive   = true
}

output "service1_lattice_dns" {
  description = "Lattice DNS — ECS service (call from pods as http://<this>/path)"
  value       = module.lattice_service1.service_dns_name
}

output "service2_lattice_dns" {
  description = "Lattice DNS — Lambda service"
  value       = module.lattice_service2.service_dns_name
}

output "service3_lattice_dns" {
  description = "Lattice DNS — EC2/ASG service"
  value       = module.lattice_service3.service_dns_name
}