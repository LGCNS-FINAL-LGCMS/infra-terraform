resource "aws_ebs_volume" "jenkins_data" {
  availability_zone = var.jenkins_az
  size              = var.jenkins_ebs_size
  type              = "gp3"
  encrypted         = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.environment}-jenkins-data"
  }
}

resource "aws_ebs_volume" "kafka_data" {
  availability_zone = var.kafka_az
  size              = var.kafka_ebs_size
  type              = "gp3"
  encrypted         = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.environment}-kafka-data"
  }
}