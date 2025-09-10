variable "environment" {
  description = "environment"
  type        = string
}

variable "aws_profile" {
  description = "AWS profile name"
  type        = string
}

variable "prometheus_az" {
  description = "Prometheus Availability zone"
  type        = string
}

variable "prometheus_ebs_size" {
  description = "Prometheus EBS size"
  type        = string
}

variable "grafana_az" {
  description = "Grafana Availability zone"
  type        = string
}

variable "grafana_ebs_size" {
  description = "Grafana EBS size"
  type        = string
}

variable "loki_az" {
  description = "Loki Availability zone"
  type        = string
}

variable "loki_ebs_size" {
  description = "Loki EBS size"
  type        = string
}

variable "tempo_az" {
  description = "Tempo Availability zone"
  type        = string
}

variable "tempo_ebs_size" {
  description = "Tempo EBS size"
  type        = string
}

variable "kafka_az" {
  description = "Kafka Availability zone"
  type        = string
}

variable "kafka_ebs_size" {
  description = "Kafka EBS size"
  type        = string
}
