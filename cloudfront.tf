# -----------------------------
# CloudFront Distribution
# -----------------------------
resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  comment             = "Rock of Ages CloudFront Distribution"
  default_root_object = "index.html"

  # -----------------------------
  # 1. Origin (S3 static website endpoint)
  # -----------------------------
  origin {
    origin_id   = "frontend-s3-origin"
    domain_name = aws_s3_bucket_website_configuration.frontend.website_endpoint

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  # -----------------------------
  # 2. Default Cache Behavior
  # -----------------------------
  default_cache_behavior {
    target_origin_id       = "frontend-s3-origin"
    viewer_protocol_policy = "allow-all"  # Allows HTTP & HTTPS

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" 
    # This is AWS's built-in CachingOptimized policy
  }

  # -----------------------------
  # 3. Price Class (optional)
  # -----------------------------
  price_class = "PriceClass_All"

  # -----------------------------
  # 4. No WAF / No custom domain
  # -----------------------------
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

//comments here