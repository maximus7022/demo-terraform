# ==========CREATING NAMESPACE FOR PROMETHEUS==========

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}

# ==========DEPLOYING PROMETHEUS OPERATOR TO CLUSTER==========

resource "helm_release" "prometheus_release" {
  name       = "kube-prometheus"
  namespace  = var.namespace
  version    = "36.2.0"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
}

# ==========CREATING SERVICE TO EXPOSE GRAFANA DASHBOARD==========

resource "kubernetes_service_v1" "grafana" {
  metadata {
    name      = "grafana-dashboard"
    namespace = var.namespace
  }

  spec {
    selector = {
      "app.kubernetes.io/instance" = "kube-prometheus"
      "app.kubernetes.io/name"     = "grafana"
    }

    port {
      protocol    = "TCP"
      port        = var.grafana_port
      target_port = var.grafana_port
    }
    type = "NodePort"
  }

  depends_on = [helm_release.prometheus_release]
}

# ==========EXPOSING GRAFANA DASHBOARD WITH ALB INGRESS==========

resource "kubernetes_ingress_v1" "grafana_ingress" {
  wait_for_load_balancer = true
  metadata {
    name      = "grafana-ingress"
    namespace = "monitoring"
    annotations = {
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/certificate-arn" : var.certificate_arn
      "alb.ingress.kubernetes.io/ssl-redirect" = 443
      "alb.ingress.kubernetes.io/load-balancer-name" : "grafana-alb"
      "alb.ingress.kubernetes.io/listen-ports" : jsonencode([{ "HTTP" = 80 }, { "HTTPS" = 443 }])
    }
  }

  spec {
    ingress_class_name = "alb"
    default_backend {
      service {
        name = kubernetes_service_v1.grafana.metadata.0.name
        port {
          number = 3000
        }
      }
    }
    rule {
      host = "grafana.${var.domain}"
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.grafana.metadata.0.name
              port {
                number = 3000
              }
            }
          }
          path = "/*"
        }
      }
    }
  }

  depends_on = [kubernetes_service_v1.grafana]
}

# ====================CREATING DNS RECORD FOR GRAFANA====================

data "aws_route53_zone" "hosted_zone" {
  name         = var.domain
  private_zone = false
}

data "aws_lb" "ingress_alb" {
  tags = {
    "ingress.k8s.aws/stack" = "monitoring/grafana-ingress"
  }

  depends_on = [kubernetes_ingress_v1.grafana_ingress]
}

resource "aws_route53_record" "grafana_lb_record" {
  name    = "grafana.${var.domain}"
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  type    = "A"

  alias {
    name                   = data.aws_lb.ingress_alb.dns_name
    zone_id                = data.aws_lb.ingress_alb.zone_id
    evaluate_target_health = true
  }
}
