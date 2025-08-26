terraform {
  backend "s3" {
    bucket       = "lgcms-terraform-state-bucket"
    key          = "infra-ebs/terraform.tfstate"
    region       = "ap-northeast-2"
    profile      = "lgcms-dev"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.9.0"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = "ap-northeast-2"
}
