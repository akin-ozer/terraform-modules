data "aws_subnet_ids" "subnets" {
  vpc_id = var.vpc_id
}

resource "aws_cloudwatch_log_group" "eks_log_group" {
  count             = length(var.cluster_enabled_log_types)
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention_in_days
  kms_key_id        = var.cluster_log_kms_key_id

  tags = merge(
    {
      "Name" = format("%s", var.cluster_name)
    },
    var.tags,
  )
}

resource "aws_eks_cluster" "eks" {
  name                      = var.cluster_name
  enabled_cluster_log_types = var.cluster_enabled_log_types
  role_arn                  = aws_iam_role.eks_role.arn
  version                   = var.cluster_version

  vpc_config {
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    security_group_ids      = []
    subnet_ids              = data.aws_subnet_ids.subnets.ids
  }

  timeouts {
    create = var.cluster_create_timeout
    delete = var.cluster_delete_timeout
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSServicePolicy,
    aws_cloudwatch_log_group.eks_log_group
  ]

  tags = merge(
    {
      "Name" = format("%s", var.cluster_name)
    },
    var.tags,
  )
}


resource "aws_security_group" "cluster_sec_group" {
  name        = "allow_cluster"
  description = "Allow cluster internal traffic"
  vpc_id      = var.vpc_id


  ingress {
    self      = true
    from_port = 0
    to_port   = 0
    protocol  = -1
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      "Name" = format("%s", var.cluster_name)
    },
    var.tags,
  )
}

resource "aws_iam_role" "eks_role" {
  name = "eks-service-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = merge(
    {
      "Name" = format("%s", var.cluster_name)
    },
    var.tags,
  )
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_role.name
}
