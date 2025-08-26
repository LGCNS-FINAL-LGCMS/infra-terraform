module "alb-irsa-role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.1.2"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn = data.terraform_remote_state.infra.outputs.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = {
    Name = "${var.environment}-alb-controller-irsa"
  }
}

resource "kubernetes_service_account" "aws_alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.alb-irsa-role.arn
    }
  }

  depends_on = [module.alb-irsa-role]
}

resource "helm_release" "aws_alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.13.4"

  timeout           = 1800
  atomic            = true
  cleanup_on_fail   = true
  dependency_update = true

  set {
    name  = "clusterName"
    value = data.terraform_remote_state.infra.outputs.aws_eks_cluster_main_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.aws_alb_controller.metadata[0].name
  }

  set {
    name  = "vpcId"
    value = data.terraform_remote_state.infra.outputs.vpc_id
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  depends_on = [kubernetes_service_account.aws_alb_controller]
}
