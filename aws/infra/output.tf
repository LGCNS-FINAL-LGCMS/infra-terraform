output "nat_gateway_eip" {
  description = "NAT Gateway EIP"
  value = aws_nat_gateway.main.public_ip
}

output "bastion_public_ip" {
  description = "Bastion host EIP address"
  value       = aws_eip.bastion.public_ip
}
