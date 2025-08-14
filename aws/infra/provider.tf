terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.8.0"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region = "ap-northeast-2"
}