data "aws_ssm_parameter" "host_secret" {
  name = "rds-host"

  depends_on = [var.depend]
}

data "aws_ssm_parameter" "database_secret" {
  name = "rds-database"

  depends_on = [var.depend]
}

data "aws_ssm_parameter" "username_secret" {
  name = "rds-username"

  depends_on = [var.depend]
}

data "aws_ssm_parameter" "password_secret" {
  name            = "rds-password"
  with_decryption = true

  depends_on = [var.depend]
}

resource "helm_release" "app_release" {
  name  = "laravel-app-release"
  chart = "./components/chart"

  values = ["${file("./components/chart/values.yaml")}"]

  set {
    name  = "container.image"
    value = var.ecr_repository
  }

  set {
    name  = "container.tag"
    value = "latest"
  }

  set {
    name  = "env.host"
    value = data.aws_ssm_parameter.host_secret.value
  }

  set {
    name  = "env.database"
    value = data.aws_ssm_parameter.database_secret.value
  }

  set {
    name  = "env.user"
    value = data.aws_ssm_parameter.username_secret.value
  }

  set {
    name  = "env.password"
    value = data.aws_ssm_parameter.password_secret.value
  }
}

resource "kubernetes_ingress_v1" "laravel_ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "laravel-ingress"
    annotations = {
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/certificate-arn" : var.certificate_arn
      "alb.ingress.kubernetes.io/ssl-redirect" = 443
      "alb.ingress.kubernetes.io/name" : "laravel-app-alb"
      "alb.ingress.kubernetes.io/listen-ports" : jsonencode([{ "HTTP" = 80 }, { "HTTPS" = 443 }])
    }
  }

  spec {
    ingress_class_name = "alb"
    default_backend {
      service {
        name = "laravel-service"
        port {
          number = 5000
        }
      }
    }
    rule {
      host = "app.${var.domain}"
      http {
        path {
          backend {
            service {
              name = "laravel-service"
              port {
                number = 5000
              }
            }
          }
          path = "/*"
        }
      }
    }
  }
}

data "aws_route53_zone" "hosted_zone" {
  name         = var.domain
  private_zone = false
}

data "aws_lb" "ingress_alb" {
  tags = {
    "ingress.k8s.aws/stack" = "default/laravel-ingress"
  }

  depends_on = [kubernetes_ingress_v1.laravel_ingress]
}

resource "aws_route53_record" "app_lb_record" {
  name    = "app.${var.domain}"
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  type    = "A"

  alias {
    name                   = data.aws_lb.ingress_alb.dns_name
    zone_id                = data.aws_lb.ingress_alb.zone_id
    evaluate_target_health = true
  }
}
