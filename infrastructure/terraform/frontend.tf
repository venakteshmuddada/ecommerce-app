resource "aws_s3_bucket" "frontend" {
  bucket = "ecommerce-frontend-${random_id.frontend_id.hex}"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags = {
    Name = "EcommerceFrontend"
  }
}

resource "random_id" "frontend_id" {
  byte_length = 4
}

# New ownership control (required by AWS)
resource "aws_s3_bucket_ownership_controls" "frontend_owner" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend_public_block" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# New bucket policy to allow public read access
resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.id

  depends_on = [
    aws_s3_bucket_public_access_block.frontend_public_block
  ]

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
}