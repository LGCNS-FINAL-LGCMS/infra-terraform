resource "aws_lb_target_group" "jenkins" {
  name        = "${var.environment}-jenkins-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.infra.outputs.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 10
    interval            = 30
    path                = "/"
    matcher             = "200,302,403"
  }
}

resource "aws_lb_target_group_attachment" "jenkins" {
  target_group_arn = aws_lb_target_group.jenkins.arn
  target_id        = data.terraform_remote_state.infra.outputs.jenkins_private_ip
  port             = 8080
}

resource "aws_lb_listener_rule" "jenkins" {
  listener_arn = data.aws_lb_listener.main.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }

  condition {
    host_header {
      values = ["jenkins.${var.domain_name}"]
    }
  }
}

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

resource "aws_security_group_rule" "alb_to_jenkins" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.infra.outputs.jenkins_security_group_id
  source_security_group_id = tolist(data.aws_lb.eks_alb.security_groups)[0]
  description              = "Allow ALB to Jenkins"
  depends_on = [data.aws_lb.eks_alb]
}
