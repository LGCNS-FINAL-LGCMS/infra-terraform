data "aws_lb_listener" "main" {
  load_balancer_arn = data.aws_lb.eks_alb.arn
  port              = 443
}

resource "null_resource" "wait_for_alb_ready" {
  provisioner "local-exec" {
    command = <<-EOF
      echo "Waiting for ALB creation to complete..."
      sleep 120
      echo "ALB creation wait completed"
    EOF
  }

  depends_on = [
    kubernetes_ingress_v1.argocd_ingress,
    kubernetes_ingress_v1.istio_ingress,
  ]
}

data "aws_lb" "eks_alb" {
  tags = {
    "ingress.k8s.aws/stack" = "eks-alb-group"
  }

  timeouts {
    read = "20m"
  }

  depends_on = [
    null_resource.wait_for_alb_ready,
  ]
}
