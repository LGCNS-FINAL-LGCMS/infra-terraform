variable "environment" {
  description = "environment"
  type = string
  default = "dev"
}

variable "aws_profile" {
  description = "AWS profile name"
  type = string
  default = "lgcms-dev"
}

variable "vpc_cidr" {
  description = "main vpc cidr"
  type = string
  default = "10.1.0.0/16"
}

variable "public_subnet_cidr" {
  description = "public subnet cidr"
  type = string
  default = "10.1.1.0/24"
}

variable "private_subnet_cidrs" {
  description = "private subnet cidrs"
  type = list(string)
  default = ["10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24"]
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access"
  type = string
  default = "0.0.0.0/0"
}

variable "ubuntu_ami_id" {
  description = "EC2 Ubuntu AMI"
  type = string
  default = "ami-09ed9bca6a01cd74a" # 64비트 ARM Ubuntu 24.04 LTS
}

variable "bastion_instance_type" {
  description = "EC2 bastion server instance type"
  type = string
  default = "t4g.nano"
}

variable "kafka_instance_type" {
  description = "EC2 bastion server instance type"
  type = string
  default = "t4g.nano"
}

variable "jenkins_instance_type" {
  description = "EC2 bastion server instance type"
  type = string
  default = "t4g.nano"
}

variable "key_name" {
  description = "Ket pair name for EC2 instances"
  type = string
  default = "lgcms-keypair"
}

variable "eks_instance_types" {
  description = "EKS Worker Nodes instance types"
  type = list(string)
  default = [
    "t4g.medium"
  ] # t4g.xlarge
}

variable "rds_instance_class" {
  description = "RDS instance Class"
  type = string
  default = "db.t4g.micro" # db.m6g.large
}

variable "rds_allocated_storage" {
  description = "RDS Allocated Storage"
  type = number
  default = 20
}

variable "db_name" {
  description = "Database name"
  type = string
  default = "lgcms"
}

variable "db_username" {
  description = "Database username"
  type = string
  default = "lgcms"
}

variable "db_password" {
  description = "Database password"
  type = string
  default = "lgcms-1234"
}

variable "cache_node_type" {
  description = "Cache Node Type"
  type = string
  default = "cache.t4g.micro"
}
