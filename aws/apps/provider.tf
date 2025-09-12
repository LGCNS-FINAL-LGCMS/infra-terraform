terraform {
  backend "s3" {
    bucket       = "lgcms-terraform-state-bucket"
    key          = "apps/terraform.tfstate"
    region       = "ap-northeast-2"
    profile      = "lgcms-dev"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.9.0"  # 6.9.0에서 변경
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5"  # 3.0.2에서 변경
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"  # 2.38.0에서 변경
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = "ap-northeast-2"

  skip_credentials_validation = false
  skip_region_validation      = false
}

data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket  = "lgcms-terraform-state-bucket"
    key     = "infra/terraform.tfstate"
    region  = "ap-northeast-2"
    profile = var.aws_profile
  }
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

data "aws_eks_cluster" "eks" {
  name = data.terraform_remote_state.infra.outputs.aws_eks_cluster_main_name
}

data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.infra.outputs.aws_eks_cluster_main_name
}

provider "helm" {
  kubernetes {
    host  = data.aws_eks_cluster.eks.endpoint
    token = data.aws_eks_cluster_auth.this.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
  }
}

provider "kubernetes" {
  host  = data.aws_eks_cluster.eks.endpoint
  token = data.aws_eks_cluster_auth.this.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
}
