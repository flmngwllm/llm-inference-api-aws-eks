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