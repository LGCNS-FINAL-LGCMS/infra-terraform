variable "environment" {
  description = "environment"
  type        = string
}

variable "aws_profile" {
  description = "AWS profile name"
  type        = string
}

variable "vpc_cidr" {
  description = "main vpc cidr"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "public subnet cidr"
  type = list(string)
}

variable "private_subnet_cidrs" {
  description = "private subnet cidrs"
  type = list(string)
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access"
  type        = string
}

variable "ubuntu_ami_id" {
  description = "EC2 Ubuntu AMI"
  type        = string
}

variable "bastion_instance_type" {
  description = "EC2 bastion server instance type"
  type        = string
}

variable "kafka_instance_type" {
  description = "EC2 kafka server instance type"
  type        = string
}

variable "kafka_ebs_mount_point" {
  description = "EC2 kafka server ebs mount point"
  type = string
}

variable "key_name" {
  description = "Ket pair name for EC2 instances"
  type        = string
}

variable "eks_instance_types" {
  description = "EKS Worker Nodes instance types"
  type = list(string)
}

variable "rds_instance_class" {
  description = "RDS instance Class"
  type        = string
}

variable "rds_allocated_storage" {
  description = "RDS Allocated Storage"
  type        = number
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
}

variable "cache_node_type" {
  description = "Cache Node Type"
  type        = string
}

variable "bastion_keypair_path" {
  description = "Bastion host keypair path"
  type        = string
}
