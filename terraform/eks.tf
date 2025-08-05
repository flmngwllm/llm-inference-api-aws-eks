resource "aws_eks_cluster" "llm_inference_api_cluster" {
  name = "llm-inference-api-cluster"

  access_config {
    authentication_mode = "API"


  }
  role_arn = aws_iam_role.llm_inference_api_eks_cluster_role.arn
  version  = "1.31"

  vpc_config {
    subnet_ids = [
      aws_subnet.public_llm_inference_api_subnet["us-east-1a"].id,
      aws_subnet.aws_subnet.public_llm_inference_api_subnet["us-east-1a"].id,
      aws_subnet.private_public_llm_inference_api_subnet["us-east-1a"].id,
      aws_subnet.private_public_llm_inference_api_subnet["us-east-1b"].id,
    ]
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.public_access_cidrs
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.llm_inference_api_cluster_AmazonEKSClusterPolicy,
  ]

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

}


resource "aws_eks_node_group" "llm_inference_api_node_group" {
  cluster_name    = aws_eks_cluster.llm_inference_api_cluster.name
  node_group_name = "llm_inference_api_node_group"
  node_role_arn   = aws_iam_role.llm_inference_api_node_group_role.arn
  subnet_ids = [aws_subnet.private_llm_inference_api_subnet["us-east-1a"].id,
  aws_subnet.private_llm_inference_api_subnet["us-east-1b"].id]
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  remote_access {
    ec2_ssh_key               = var.ssh_key_name
    source_security_group_ids = [aws_security_group.llm_inference_api_eks_nodes_sg.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_eks_cluster.llm_inference_api_cluster,
    aws_iam_role_policy_attachment.llm_inference_api_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.llm_inference_api_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.llm_inference_api_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.llm_inference_api_ssm
  ]

}




