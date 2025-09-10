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


resource "kubernetes_ingress_v1" "istio_ingress_sse" {
  metadata {
    name      = "istio-ingress-sse"
    namespace = "istio-system"
    annotations = {
      "kubernetes.io/ingress.class"                        = "alb"
      "alb.ingress.kubernetes.io/scheme"                   = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"              = "ip"
      "alb.ingress.kubernetes.io/certificate-arn"          = data.aws_acm_certificate.ssl_cert.arn
      "alb.ingress.kubernetes.io/listen-ports"             = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"             = "443"
      "alb.ingress.kubernetes.io/group.name"               = "eks-alb-group"
      "alb.ingress.kubernetes.io/subnets" = join(",", data.terraform_remote_state.infra.outputs.public_subnet_ids)
      "alb.ingress.kubernetes.io/group.order"              = 10
      "alb.ingress.kubernetes.io/load-balancer-attributes" = "idle_timeout.timeout_seconds=3600"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = "api.${var.domain_name}"
      http {
        path {
          path      = "/student/notification/subscribe"
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
      "alb.ingress.kubernetes.io/group.order"     = 20
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

    rule {
      host = "kiali.${var.domain_name}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "kiali"
              port {
                number = 20001
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

resource "kubernetes_ingress_v1" "monitoring_ingress" {
  metadata {
    name      = "monitoring-ingress"
    namespace = "monitoring"
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
      host = "grafana.${var.domain_name}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "prometheus-grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    rule {
      host = "prometheus.${var.domain_name}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "prometheus-grafana-kube-pr-prometheus"
              port {
                number = 9090
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.aws_alb_controller]
}

resource "kubernetes_ingress_v1" "airflow_ingress" {
  metadata {
    name      = "airflow-ingress"
    namespace = "airflow"
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
      host = "airflow.${var.domain_name}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "airflow-api-server"
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
