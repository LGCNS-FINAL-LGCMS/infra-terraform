resource "aws_instance" "bastion" {
  ami = var.ubuntu_ami_id
  instance_type = var.bastion_instance_type
  key_name = var.key_name
  subnet_id = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.bastion.id]

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted = true
  }

  tags = {
    Name = "${var.environment}-bastion"
  }
}
