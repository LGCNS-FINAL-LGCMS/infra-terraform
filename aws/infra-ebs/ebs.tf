resource "aws_ebs_volume" "prometheus_data" {
  availability_zone = var.prometheus_az
  size              = var.prometheus_ebs_size
  type              = "gp3"
  encrypted         = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.environment}-prometheus-data"
  }
}

resource "aws_ebs_volume" "grafana_data" {
  availability_zone = var.grafana_az
  size              = var.grafana_ebs_size
  type              = "gp3"
  encrypted         = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.environment}-grafana-data"
  }
}

resource "aws_ebs_volume" "loki_data" {
  availability_zone = var.loki_az
  size              = var.loki_ebs_size
  type              = "gp3"
  encrypted         = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.environment}-loki-data"
  }
}

resource "aws_ebs_volume" "tempo_data" {
  availability_zone = var.tempo_az
  size              = var.tempo_ebs_size
  type              = "gp3"
  encrypted         = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "${var.environment}-tempo-data"
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