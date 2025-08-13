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
        Action = ["s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectTagging",
          "s3:GetObjectVersion",
        "s3:GetObjectVersionTagging"],
        Resource = [
          "${aws_s3_bucket.llm_inference_api_ci_artifacts.arn}",
          "${aws_s3_bucket.llm_inference_api_ci_artifacts.arn}/*"
        ]
      }
    ]
  })
  depends_on = [aws_iam_role.llm_inference_api_github_actions]
}

resource "aws_s3_bucket" "llm_inference_api_terraform_state" {
  bucket = "llm-inference-api-terraform-state"

  tags = {
    Project = "llm-inference-api-eks"
    Purpose = "Terraform State Storage"
  }

}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.llm_inference_api_terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.llm_inference_api_terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket                  = aws_s3_bucket.llm_inference_api_terraform_state.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}