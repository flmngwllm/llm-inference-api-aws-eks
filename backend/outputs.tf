output "github_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.llm_github.arn
}

output "github_oidc_provider_url" {
  value = aws_iam_openid_connect_provider.llm_github.url
}

output "ci_artifacts_bucket_name" {
  value = aws_s3_bucket.llm_inference_api_ci_artifacts.bucket
}