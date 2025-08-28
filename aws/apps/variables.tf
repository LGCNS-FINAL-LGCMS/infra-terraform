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

variable "backend_auth_chart_version" {
  description = "backend auth server chart version"
  type        = string
}

variable "backend_member_chart_version" {
  description = "backend member server chart version"
  type        = string
}

variable "backend_lecture_chart_version" {
  description = "backend lecture server chart version"
  type        = string
}

variable "backend_core_chart_version" {
  description = "backend core server chart version"
  type        = string
}

variable "backend_guide_chart_version" {
  description = "backend guide server chart version"
  type        = string
}

variable "backend_lesson_chart_version" {
  description = "backend lesson server chart version"
  type        = string
}

variable "frontend_chart_version" {
  description = "frontend server chart version"
  type        = string
}