resource "aws_iam_role" "llm_inference_api_eks_cluster_role" {
  name = "llm_inference_api_eks_cluster_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name        = "llm_inference_api_eks_cluster_role"
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role" "llm_inference_api_node_group_role" {
  name = "llm_inference_api_node_group"

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

  tags = {
    Name        = "llm_inference_api_node_group_role"
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "llm_inference_api_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.llm_inference_api_eks_cluster_role.name
}


resource "aws_iam_role_policy_attachment" "llm_inference_api_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.llm_inference_api_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "llm_inference_api_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.llm_inference_api_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "llm_inference_api_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.llm_inference_api_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "llm_inference_api_nodes_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.llm_inference_api_node_group_role.name
}

data "aws_iam_policy_document" "llm_alb_controller_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.llm_inference_api_eks_oidc.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.llm_inference_api_eks_oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-alb-controller"]
    }
  }
}

resource "aws_iam_role" "llm_inference_api_alb_controller_role" {
  name               = "llm_inference_api_alb_controller_role"
  assume_role_policy = data.aws_iam_policy_document.llm_alb_controller_trust.json
  tags = {
    Name        = "llm_inference_api_alb_controller_role"
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_policy" "llm_inference_api_alb_controller_policy" {
  name   = "llm_inference_api_alb_controller_policy"
  policy = file("${path.module}/policy/llm_aws_alb_policy.json")

}

resource "aws_iam_role_policy_attachment" "llm_inference_api_alb_attachment" {
  policy_arn = aws_iam_policy.llm_inference_api_alb_controller_policy.arn
  role       = aws_iam_role.llm_inference_api_alb_controller_role.name
}