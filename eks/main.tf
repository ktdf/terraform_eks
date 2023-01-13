resource "aws_iam_role" "this" {
  name = "eks_role"
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

resource "aws_kms_key" "this" {
  description             = "Key for kms secrets encryption"
  deletion_window_in_days = "7"
  tags = {
    "Name" = "terraform secrets key"
  }
}

resource "aws_eks_cluster" "this" {
  name = "testcluster"

  role_arn = aws_iam_role.this.arn
  vpc_config {
    subnet_ids = var.cluster_subnets
  }
  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.this.arn
    }
  }

  depends_on = [aws_iam_role.this]
}