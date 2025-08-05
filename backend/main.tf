provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "llm-inference-api-terraform-state"
    key            = "bootstrap/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "llm-inference-api-terraform-locks"
    encrypt        = true
  }
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

