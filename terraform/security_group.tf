resource "aws_security_group" "llm_inference_api_eks_nodes_sg" {
  name        = "llm_inference_api_eks_nodes_sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.llm_inference_api_vpc.id

  ingress {
    description = "Allow all node-to-node"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "llm_inference_api_eks_nodes_sg"
  }
}