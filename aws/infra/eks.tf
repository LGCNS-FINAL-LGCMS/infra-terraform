module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.1.0"

  name               = "${var.environment}-eks-cluster"
  kubernetes_version = "1.32"

  vpc_id                  = aws_vpc.main.id
  subnet_ids              = aws_subnet.private[*].id
  endpoint_public_access  = true
  endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true

  create_iam_role = true
  iam_role_name   = "${var.environment}-eks-cluster-role"

  node_security_group_additional_rules = {
    istio_webhook = {
      description                   = "Istio sidecar injector webhook"
      protocol                      = "tcp"
      from_port                     = 15017
      to_port                       = 15017
      type                          = "ingress"
      source_cluster_security_group = true
    }
    istio_discovery = {
      description                   = "Istio discovery"
      protocol                      = "tcp"
      from_port                     = 15012
      to_port                       = 15012
      type                          = "ingress"
      source_cluster_security_group = true
    }
    kafka_egress = {
      desciption                    = "Kafka egress"
      protocol                      = "tcp"
      from_port                     = 9094
      to_port                       = 9094
      type                          = "egress"
      source_cluster_security_group = true
    }
    metrics_server = {
      desciption                    = "Metrics server"
      protocol                      = "tcp"
      from_port                     = 10251
      to_port                       = 10251
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  enable_irsa = true

  addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
    metrics-server = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
      resolve_conflicts        = "OVERWRITE"
    }
  }

  eks_managed_node_groups = {
    main = {
      name = "${var.environment}-eks-workers"

      create_iam_role = true
      iam_role_name   = "${var.environment}-eks-cluster-workers"

      iam_role_additional_policies = {
        AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
        AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }

      instance_types = var.eks_instance_types

      min_size     = 3
      max_size     = 3
      desired_size = 3

      disk_size = 20

      ami_type = "AL2_ARM_64"

      update_config = {
        max_unavailable = 1
      }

      subnet_ids = aws_subnet.private[*].id

      tags = {
        Name = "${var.environment}-eks-workers"
      }
    }
  }

  tags = {
    Name = "${var.environment}-eks-cluster"
  }
}

module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.1.0"

  role_name             = "${var.environment}-ebs-csi-controller-role"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = {
    Name = "${var.environment}-ebs-csi-controller-role"
  }
}