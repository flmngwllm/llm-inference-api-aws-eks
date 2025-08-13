output "cluster_name" {
  value = aws_eks_cluster.llm_inference_api_cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.llm_inference_api_cluster.endpoint
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.llm_inference_api_cluster.certificate_authority[0].data
}

output "node_group_name" {
  value = aws_eks_node_group.llm_inference_api_node_group.node_group_name
}

output "vpc_id" {
  value = aws_vpc.llm_inference_api_vpc.id
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.llm_inference_api_repo.repository_url
  description = "URL of the ECR repository to push images"
}

output "gha_admin_policy_arn" {
  value = aws_eks_access_policy_association.llm_inference_gha_admin.policy_arn
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.llm_s3_distribution.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.llm_s3_distribution.id
}

output "frontend_bucket_name" {
  value = aws_s3_bucket.llm_frontend_assets.id
}

output "artifacts_bucket_name" {
  description = "CI artifacts bucket name"
  value       = local.artifacts_bucket_name
}