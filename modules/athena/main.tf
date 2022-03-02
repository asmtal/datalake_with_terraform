/*
This is an example of how to build a resource only in a certain environment, in which case, 
with this configuration Athena would only be configured in the production environment.
As Athena makes use of a specific bucket, we perform the bucket setup according to the environment as well.
*/
resource "aws_s3_bucket" "bucket_raw" {
  count  = var.env == "prod" ? 1 : 0
  bucket = "name-bucket-rawzone"
  acl    = "private"

  tags = var.instance_tags_raw

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
      }
    }
  }
  logging {
    target_bucket = var.bucket_logs
    target_prefix = "log/"
  }

}

resource "aws_athena_database" "athena-dev" {
  count  = var.env == "prod" ? 1 : 0
  name   = "name_athena_database"
  bucket = aws_s3_bucket.bucket_raw[count.index].bucket
}