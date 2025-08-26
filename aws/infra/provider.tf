terraform {
  backend "s3" {
    bucket       = "lgcms-terraform-state-bucket"
    key          = "infra/terraform.tfstate"
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
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = "ap-northeast-2"
}

data "terraform_remote_state" "infra-ebs" {
  backend = "s3"
  config = {
    bucket  = "lgcms-terraform-state-bucket"
    key     = "infra-ebs/terraform.tfstate"
    region  = "ap-northeast-2"
    profile = var.aws_profile
  }
}
