# KMS Key configuration
resource "aws_kms_key" "bucket_new_key" {
  description         = "This key is used to encrypt bucket objects"
  enable_key_rotation = true
}

# Bucket for record logs
resource "aws_s3_bucket" "bucket_log" {
  bucket = "name-bucket-log"
  acl    = "log-delivery-write"

  tags = var.instance_tags_log
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

}


# Buckets for raw and refined data
resource "aws_s3_bucket" "bucket_refined" {
  bucket = "name-bucket-refined-zone"
  acl    = "private"

  tags = var.instance_tags_refined

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
  logging {
    target_bucket = aws_s3_bucket.bucket_log.id
    target_prefix = "log/refined/"
  }

}

resource "aws_s3_bucket" "bucket_raw" {
  bucket = "name-bucket-raw-zone"
  acl    = "private"

  tags = var.instance_tags_raw

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
  logging {
    target_bucket = aws_s3_bucket.bucket_log.id
    target_prefix = "log/rawzone/"
  }

}

# Bucket to stored Python/Pyspark scripts
resource "aws_s3_bucket" "bucket_scripts" {
  bucket = "name-bucket-scripts"
  acl    = "private"

  tags = var.instance_tags_scripts

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
  logging {
    target_bucket = aws_s3_bucket.bucket_log.id
    target_prefix = "log/scripts/"
  }

}

# Bucket for Sandbox
resource "aws_s3_bucket" "bucket_sandbox" {
  bucket = "name-bucket-sandbox"
  acl    = "private"

  tags = var.instance_tags_sandbox

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
  logging {
    target_bucket = aws_s3_bucket.bucket_log.id
    target_prefix = "log/sandbox/"
  }
}

# Bucket for SFTP Transfer
resource "aws_s3_bucket" "bucket_transfer" {
  bucket = "name-bucket-transfer"
  acl    = "private"

  tags = var.instance_tags_transfer

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
  logging {
    target_bucket = aws_s3_bucket.bucket_log.id
    target_prefix = "log/transfer/"
  }

}

# Bucket for transient step in ETL process 
resource "aws_s3_bucket" "bucket_transient" {
  bucket = "name-bucket-transient"
  acl    = "private"

  tags = var.instance_tags_transient

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
  logging {
    target_bucket = aws_s3_bucket.bucket_log.id
    target_prefix = "log/transient/"
  }

}

# load objects in buckets
resource "aws_s3_bucket_object" "buckets_objects" {
  count  = length(var.bucket_objects)
  bucket = aws_s3_bucket.bucket_scripts.id
  acl    = "private"
  key    = var.bucket_objects[count.index]
  source = var.bucket_sources[count.index]
}

# Creating directories in bucket s3.
resource "aws_s3_bucket_object" "sandbox_folders" {
  count  = length(var.sandbox_groups)
  bucket = aws_s3_bucket.bucket_sandbox.id
  acl    = "private"
  key    = "${var.sandbox_groups[count.index]}/"
  source = "/dev/null"
}
