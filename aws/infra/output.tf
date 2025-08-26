output "nat_gateway_eip" {
  description = "NAT Gateway EIP"
  value       = aws_nat_gateway.main.public_ip
}

output "bastion_public_ip" {
  description = "Bastion host EIP address"
  value       = aws_eip.bastion.public_ip
}

output "jenkins_private_id" {
  description = "Jenkins id"
  value       = aws_instance.jenkins.id
}

output "jenkins_private_ip" {
  description = "Jenkins host private ip"
  value       = aws_instance.jenkins.private_ip
}

output "jenkins_security_group_id" {
  description = "Jenkins security group id"
  value       = aws_security_group.jenkins.id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "aws_eks_cluster_main_name" {
  value = module.eks.cluster_name
}

output "aws_db_instance_main_address" {
  value = aws_db_instance.main.address
}

output "aws_db_instance_main_port" {
  value = aws_db_instance.main.port
}

output "aws_db_username" {
  value = var.db_username
}

output "aws_db_password" {
  value = var.db_password
}

output "aws_cache_main_address" {
  value = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "aws_cache_main_port" {
  value = aws_elasticache_replication_group.main.port
}

output "environment" {
  value = var.environment
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}