resource "aws_s3_bucket" "web_storage" {
  bucket_prefix = "web-app-storage"
  tags          = {
    Name = "web-app-storage"
  }
}
