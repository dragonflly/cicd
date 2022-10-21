# S3 bucket for backend as Remote State Storage
resource "aws_s3_bucket" "terraform-on-eks" {
  bucket = "terraform-on-eks"

  tags = {
    Name = "Backend Terraform Remote State Bucket"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "terraform-on-eks" {
  bucket = aws_s3_bucket.terraform-on-eks.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
