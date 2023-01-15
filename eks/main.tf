locals {
  node_subnets = length(var.node_subnets) > 0 ? var.node_subnets : var.cluster_subnets
}


resource "aws_iam_role" "cluster" {
  name = "eks_role_cluster"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
}

resource "aws_iam_role" "node_group" {
  name = "eks_role_node_group"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ]
}

resource "aws_kms_key" "this" {
  description             = "Key for kms secrets encryption"
  deletion_window_in_days = "7"
  tags = {
    "Name" = "terraform secrets key"
  }
}

resource "aws_eks_cluster" "this" {
  name = var.cluster_name

  role_arn = aws_iam_role.cluster.arn
  vpc_config {
    subnet_ids = var.cluster_subnets
  }
  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.this.arn
    }
  }

  depends_on = [
    aws_iam_role.cluster,
    aws_iam_role.node_group
  ]
}

resource "aws_eks_addon" "this" {
  count = length(var.addons)

  addon_name   = element(var.addons, count.index)
  cluster_name = aws_eks_cluster.this.id
}

resource "aws_eks_node_group" "this" {
  cluster_name   = aws_eks_cluster.this.id
  node_role_arn  = aws_iam_role.node_group.arn
  subnet_ids     = local.node_subnets
  instance_types = ["t3.micro"]
  disk_size      = 8
  scaling_config {
    desired_size = var.node_group_size["desired"]
    max_size     = var.node_group_size["max"]
    min_size     = var.node_group_size["min"]
  }

  depends_on = [
    aws_iam_role.cluster,
    aws_iam_role.node_group
  ]
}