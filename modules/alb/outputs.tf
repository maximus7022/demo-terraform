output "lb_arn" {
  value = aws_lb.lb.arn
}

output "lb_dns_name" {
  value = aws_lb.lb.dns_name
}

output "lb_zone_id" {
  value = aws_lb.lb.zone_id
}

output "certificate_arn" {
  value = aws_acm_certificate.cert.arn
}
