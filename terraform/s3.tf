resource "aws_s3_bucket" "llm_frontend_assets" {
    bucket = var.BUCKET_NAME
    force_destroy = true
    
}

resource "aws_s3_bucket_public_access_block" "initial" {
  bucket = aws_s3_bucket.llm_frontend_assets.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}



resource "aws_s3_bucket_policy" "bucket_policy" {
  depends_on = [aws_s3_bucket_public_access_block.initial]

  bucket = aws_s3_bucket.llm_frontend_assets.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCloudFrontReadViaOAC"
        Action    = "s3:GetObject",
        Effect    = "Allow",
        Resource  = "arn:aws:s3:::${aws_s3_bucket.llm_frontend_assets.id}/*",
        Principal = { Service = "cloudfront.amazonaws.com" },
        Condition = {
        StringEquals = {
          "AWS:SourceArn" : aws_cloudfront_distribution.llm_s3_distribution.arn
        }
      }
      }
    ]
  })
}


