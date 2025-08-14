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
