output "kms_key" {
  value = aws_kms_key.bucket_new_key.arn
}
output "bucket_log" {
  value = aws_s3_bucket.bucket_log.id

}
output "bucket_id" {
  value = aws_s3_bucket.bucket_transfer.id
}

output "bucket_arn" {
  value = aws_s3_bucket.bucket_transfer.arn
}