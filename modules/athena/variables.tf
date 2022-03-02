variable "env" {
  type = string
}

variable "bucket_logs" {

}

variable "instance_tags_raw" {
  type = map(string)

  description = ""

  default = {
    Name      = "BucketRawZone"
    ManagedBy = "Terraform"
    CreatedAt  = "2022-03-02"
  }

}