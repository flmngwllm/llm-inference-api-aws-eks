resource "aws_cloudfront_origin_access_control" "S3_OAC" {
  name              = "s3_static-oac"
  description       = "OAC for S3 bucket ${var.BUCKET_NAME}"
  origin_access_control_origin_type = "s3"
  signing_behavior  = "always"
  signing_protocol  = "sigv4"
}


locals {
  s3_origin_id = "S3-${var.BUCKET_NAME}"
}


resource "aws_cloudfront_distribution" "llm_s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.llm_frontend_assets.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.S3_OAC.id
    origin_id                = local.s3_origin_id
  }

    enabled             = true
    is_ipv6_enabled     = true
    comment             = "CloudFront distribution for LLM Inference API frontend assets"
    default_root_object = "index.html"
    price_class = "PriceClass_100"

   


  default_cache_behavior {
    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    origin_request_policy_id   = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # AllViewer
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]


    viewer_protocol_policy = "redirect-to-https"
    target_origin_id = local.s3_origin_id
    compress = true
  }
  
custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }
  

restrictions {
  geo_restriction {
    restriction_type = "none"
   
  }
}
  tags = {
    Environment = "production"
  }

  viewer_certificate {
  cloudfront_default_certificate = true
  ssl_support_method             = "sni-only"
  minimum_protocol_version       = "TLSv1.2_2021"
}

}

