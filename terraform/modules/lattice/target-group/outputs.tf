output "target_group_id" {
  description = "ID of the target group"
  value       = aws_vpclattice_target_group.this.id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_vpclattice_target_group.this.arn
}

output "target_group_name" {
  description = "Name of the target group"
  value       = aws_vpclattice_target_group.this.name
}

output "attachment_ids" {
  description = "Map of target attachment IDs"
  value       = { for k, v in aws_vpclattice_target_group_attachment.this : k => v.id }
}