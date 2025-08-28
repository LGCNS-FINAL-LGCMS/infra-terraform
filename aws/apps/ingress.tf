data "aws_acm_certificate" "ssl_cert" {
  domain      = var.acm_domain_name
  statuses = ["ISSUED"]
  most_recent = true
}

resource "kubernetes_ingress_v1" "frontend_ingress" {
  metadata {
    name      = "frontend-ingress"
    namespace = "frontend"
    annotations = {
      "kubernetes.io/ingress.class"                    = "alb"
      "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"          = "ip"
      "alb.ingress.kubernetes.io/certificate-arn"      = data.aws_acm_certificate.ssl_cert.arn
      "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"         = "443"
      "alb.ingress.kubernetes.io/group.name"           = "eks-alb-group"
      "alb.ingress.kubernetes.io/subnets" = join(",", data.terraform_remote_state.infra.outputs.public_subnet_ids)
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = "www.${var.domain_name}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "frontend"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.aws_alb_controller]
}


resource "kubernetes_ingress_v1" "istio_ingress" {
  metadata {
    name      = "istio-ingress"
    namespace = "istio-system"
    annotations = {
      "kubernetes.io/ingress.class"               = "alb"
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/certificate-arn" = data.aws_acm_certificate.ssl_cert.arn
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      "alb.ingress.kubernetes.io/group.name"      = "eks-alb-group"
      "alb.ingress.kubernetes.io/subnets" = join(",", data.terraform_remote_state.infra.outputs.public_subnet_ids)
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = "api.${var.domain_name}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "istio-ingressgateway"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.aws_alb_controller]
}


resource "kubernetes_ingress_v1" "argocd_ingress" {
  metadata {
    name      = "argocd-ingress"
    namespace = "argocd"
    annotations = {
      "kubernetes.io/ingress.class"               = "alb"
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/certificate-arn" = data.aws_acm_certificate.ssl_cert.arn
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      "alb.ingress.kubernetes.io/group.name"      = "eks-alb-group"
      "alb.ingress.kubernetes.io/subnets" = join(",", data.terraform_remote_state.infra.outputs.public_subnet_ids)
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = "argo.${var.domain_name}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argo-cd-argocd-server"
              port {
                number = 443
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.aws_alb_controller]
}
