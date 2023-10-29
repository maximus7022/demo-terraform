resource "aws_security_group" "eks_api_private_access" {
  name   = "eks-api-private-access"
  vpc_id = var.vpc_id

  tags = merge(var.tags, tomap({ "Name" = "${var.env}-eks-api-private-access" }))
}

resource "aws_security_group_rule" "inbound_rule_allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.eks_api_private_access.id
}

resource "aws_security_group_rule" "outbound_rule_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_api_private_access.id
}

# IAM ROLE FOR EKS CLUSTER
data "aws_iam_policy_document" "demo_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "demo_eks_role" {
  name               = "${var.cluster_name}-role"
  assume_role_policy = data.aws_iam_policy_document.demo_role_policy.json

  tags = merge(var.tags, tomap({ "Name" = "${var.cluster_name}-role" }))
}

resource "aws_iam_role_policy_attachment" "demo_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.demo_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "demo_AmazonEKSVPCResourceController" {
  role       = aws_iam_role.demo_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# IAM ROLE FOR NODES
resource "aws_iam_role" "demo_node_role" {
  name = "eks-node-group-demo-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "demo_node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.demo_node_role.name
}

resource "aws_iam_role_policy_attachment" "demo_node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.demo_node_role.name
}

resource "aws_iam_role_policy_attachment" "demo_node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.demo_node_role.name
}

#IAM ROLE FOR SERVICE ACCOUNT
data "aws_iam_policy_document" "demo_service_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.demo_openid.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.demo_openid.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.demo_openid.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "aws_load_balancer_controller_role" {
  assume_role_policy = data.aws_iam_policy_document.demo_service_role_policy.json
  name               = "aws-load-balancer-controller"

  tags = merge(var.tags, tomap({ "Name" = "aws-load-balancer-controller" }))
}

resource "aws_iam_policy" "ingress_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "ALB Ingress Controller IAM Policy"
  policy      = file("components/policy/elb-iam-policy.json")

  tags = merge(var.tags, tomap({ "Name" = "AWSLoadBalancerControllerIAMPolicy" }))
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_role_AWSLoadBalancerControllerIAMPolicy" {
  role       = aws_iam_role.aws_load_balancer_controller_role.name
  policy_arn = aws_iam_policy.ingress_policy.arn
}
