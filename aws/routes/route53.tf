data "aws_lb" "alb" {
  tags = {
    "ingress.k8s.aws/stack" = "eks-alb-group"
  }

  timeouts {
    read = "30m"
  }
}

data "aws_route53_zone" "dns" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.dns.zone_id
  name = "www.${var.domain_name}"
  type    = "A"

  alias {
    # name                   =
    name                   = data.aws_lb.alb.dns_name
    zone_id                = data.aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.dns.zone_id
  name    = "api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = data.aws_lb.alb.dns_name
    zone_id                = data.aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "argo" {
  zone_id = data.aws_route53_zone.dns.zone_id
  name    = "argo.${var.domain_name}"
  type    = "A"

  alias {
    name                   = data.aws_lb.alb.dns_name
    zone_id                = data.aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
