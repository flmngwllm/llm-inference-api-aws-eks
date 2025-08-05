resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "llm_inference_api_ci_artifacts" {
  bucket        = "llm-inference-api-artifacts-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name = "CI Artifacts Bucket"
  }
}


resource "aws_s3_bucket_policy" "llm_inference_api_ci_artifacts_policy" {
  bucket = aws_s3_bucket.llm_inference_api_ci_artifacts.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowGitHubActionsAccess",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::831274730062:role/llm-inference-api-github-actions-role"
        },
        Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"],   
         Resource = [
          "${aws_s3_bucket.llm_inference_api_ci_artifacts.arn}",
          "${aws_s3_bucket.llm_inference_api_ci_artifacts.arn}/*"
         ]
      }
    ]
  })
}