variable "instance_tags_tfstate" {
  type = map(string)

  description = "Tags for the tfstate bucket"

  default = {
    Name      = "BucketTFState"
    ManagedBy = "Terraform"
    CreatedAt  = "2022-03-02"
  }

}

variable "instance_tags_refined" {
  type = map(string)

  description = "Tags for the refined bucket"

  default = {
    Name      = "BucketRefinedZone"
    ManagedBy = "Terraform"
    CreatedAt  = "2022-03-02"
  }

}

variable "instance_tags_raw" {
  type = map(string)

  description = "Tags for the raw bucket"

  default = {
    Name      = "BucketRawZone"
    ManagedBy = "Terraform"
    CreatedAt  = "2022-03-02"
  }

}

variable "instance_tags_scripts" {
  type = map(string)

  description = "Tags for the scripts bucket"

  default = {
    Name      = "BucketScript"
    ManagedBy = "Terraform"
    CreatedAt  = "2022-03-02"
  }

}

variable "instance_tags_sandbox" {
  type = map(string)

  description = "Tags for the sandbox bucket"

  default = {
    Name      = "BucketSandbox"
    ManagedBy = "Terraform"
    CreatedAt  = "2022-03-02"
  }

}

variable "instance_tags_transfer" {
  type = map(string)

  description = "Tags for the transfer bucket"

  default = {
    Name      = "BucketTransfer"
    ManagedBy = "Terraform"
    CreatedAt  = "2022-03-02"
  }

}


variable "instance_tags_transient" {
  type = map(string)

  description = "Tags for the transient bucket"

  default = {
    Name      = "BucketTransient"
    ManagedBy = "Terraform"
    CreatedAt  = "2022-03-02"
  }
}
variable "env" {
  type = string
}

variable "sandbox_groups" {
  default = [
    "data-science",
    "financial-operation",
    "marketing-sales",
    "information_technology",
    "data-engineering"
  ]
}

variable "bucket_objects" {
  default = [
    "initial_ingestion_with_dump.py",
    "initial_ingestion_without_dump.py",
    "incremental_ingestion_by_batch.py",
    "create_datamart_example.py"
  ]

}

variable "bucket_sources" {
  default = [
    "../scripts/glue-a/initial_ingestion_with_dump.py",
    "../scripts/glue-a/initial_ingestion_without_dump.py",
    "../scripts/glue-a/incremental_ingestion_by_batch.py",
    "../scripts/glue-b/create_datamart_example.py"
  ]

}
