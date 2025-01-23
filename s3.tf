resource "aws_s3_bucket" "pegaso_bucket" {
  bucket = local.s3-sufix
  tags = {
    Name = "Jenkins-Server"
  }

}

resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket     = aws_s3_bucket.pegaso_bucket.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.pegaso_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}