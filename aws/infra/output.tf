output "nat_gateway_eip" {
  description = "NAT Gateway EIP"
  value = aws_nat_gateway.main.public_ip
}
