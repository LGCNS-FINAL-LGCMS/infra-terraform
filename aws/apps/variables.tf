variable "environment" {
  description = "environment"
  type        = string
}

variable "aws_profile" {
  description = "AWS profile name"
  type        = string
}

variable "domain_name" {
  description = "DNS domain name"
  type        = string
}

variable "acm_domain_name" {
  description = "ACM domain name"
  type        = string
}

variable "aws_region" {
  description = "AWS EKS Region"
  type        = string
}