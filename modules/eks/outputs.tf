output "eks_endpoint" {
  value = data.aws_eks_cluster.demo_cluster.endpoint
}

output "eks_certificate_authority" {
  value = data.aws_eks_cluster.demo_cluster.certificate_authority[0].data
}

output "eks_auth_token" {
  value = data.aws_eks_cluster_auth.demo_cluster.token
}
