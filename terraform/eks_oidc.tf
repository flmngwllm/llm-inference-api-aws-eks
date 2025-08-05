resource "aws_iam_openid_connect_provider" "llm_inference_api_eks_oidc" {
  url             = aws_eks_cluster.llm_inference_api_cluster.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0ecd2e0e0"]
  depends_on      = [aws_eks_cluster.llm_inference_api_cluster]
}