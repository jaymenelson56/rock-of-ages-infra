# -----------------------------
# 1. Create the S3 Bucket
# -----------------------------
resource "aws_s3_bucket" "frontend" {
  bucket = var.bucket_name
  force_destroy = true # optional: allows deleting bucket even if it has objects

  tags = {
    Name = "Rock of Ages Frontend Bucket"
  }
}

# -----------------------------
# 2. Disable Block Public Access
# -----------------------------
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# -----------------------------
# 3. Enable Static Website Hosting
# -----------------------------
resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# -----------------------------
# 4. Public Read Bucket Policy
# -----------------------------
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.frontend]
}