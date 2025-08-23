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

resource "aws_instance" "jenkins" {
  ami = var.ubuntu_ami_id
  instance_type = var.jenkins_instance_type
  key_name = var.key_name
  subnet_id = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.app.id]

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    encrypted = true
  }

  user_data = <<-EOF
              #! /bin/bash
              apt-get update
              touch /hello-jenkins
              EOF

  tags = {
    Name = "${var.environment}-jenkins"
  }
}

resource "aws_instance" "kafka" {
  ami = var.ubuntu_ami_id
  instance_type = var.kafka_instance_type
  key_name = var.key_name
  subnet_id = aws_subnet.private[1].id
  vpc_security_group_ids = [aws_security_group.kafka.id]

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    encrypted = true
  }

  user_data = <<-EOF
              #! /bin/bash
              apt-get update
              touch /hello-kafka
              EOF

  tags = {
    Name = "${var.environment}-kafka"
  }
}