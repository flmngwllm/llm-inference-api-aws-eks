resource "aws_cloudfront_origin_access_control" "llm_S3_OAC" {
  name                              = "llm_s3_static-oac"
  description                       = "OAC for S3 bucket ${var.BUCKET_NAME}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


data "aws_s3_object" "api_base_url" {
  bucket = var.artifacts_bucket_name
  key    = "api_base_url.txt"
}


locals {
  s3_origin_id = "S3-${var.BUCKET_NAME}"
  api_hostname = replace(
    replace(trimspace(data.aws_s3_object.api_base_url.body), "https://", ""),
    "http://",
    ""
  )
  api_hostname_clean = trimsuffix(local.api_hostname, "/")
}


resource "aws_cloudfront_distribution" "llm_s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.llm_frontend_assets.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.llm_S3_OAC.id
    origin_id                = local.s3_origin_id
  }

  #API (ALB) origin — CF -> ALB over HTTP
  origin {
    domain_name = local.api_hostname_clean # e.g. k8s-...elb.amazonaws.com
    origin_id   = "api-alb"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # keep ALB plain HTTP; browser remains HTTPS to CF
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for LLM Inference API frontend assets"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"


  #route /api/* to ALB, no cache, forward everything (to avoid CORS issues)
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "api-alb"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"]
    cached_methods  = ["GET", "HEAD"]

    # legacy forwarding block is fine; forward all headers/cookies, and queries
    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies { forward = "all" }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  default_cache_behavior {
    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    origin_request_policy_id   = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # AllViewer
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]


    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = local.s3_origin_id
    compress               = true
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

