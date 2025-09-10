variable "environment" {
  description = "environment"
  type        = string
}

variable "aws_profile" {
  description = "AWS profile name"
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
