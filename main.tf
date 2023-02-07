resource "aws_s3_bucket" "b" {
  bucket = "devops-madetech-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}