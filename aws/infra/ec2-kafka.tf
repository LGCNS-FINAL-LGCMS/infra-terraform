data "aws_ebs_volume" "kafka_data" {
  most_recent = true

  filter {
    name = "volume-type"
    values = [data.terraform_remote_state.infra-ebs.outputs.kafka_ebs_type]
  }

  filter {
    name = "tag:Name"
    values = [data.terraform_remote_state.infra-ebs.outputs.kafka_tag_Name]
  }
}

resource "aws_instance" "kafka" {
  ami           = var.ubuntu_ami_id
  instance_type = var.kafka_instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.private[1].id
  vpc_security_group_ids = [aws_security_group.kafka.id]

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  user_data_base64 = base64encode(templatefile("${path.module}/scripts/mount_and_docker-compose-kafka.sh", {
    mount_point = var.kafka_ebs_mount_point,
    docker_compose_content = templatefile("${path.module}/docker/docker-compose-kafka.yaml", {
      mount_point = var.kafka_ebs_mount_point,
    })
  }))

  tags = {
    Name = "${var.environment}-kafka"
  }
}

resource "aws_volume_attachment" "kafka_attach" {
  device_name  = "/dev/sdf"
  instance_id  = aws_instance.kafka.id
  volume_id    = data.aws_ebs_volume.kafka_data.id
  force_detach = true
}
