/*
this workflow is used to orchestrate the crawlers and jobs to perform the initial load with dump files
*/
resource "aws_glue_workflow" "workflow-initial-load" {
  count = length(var.tables)
  name  = "workflow-ingestion-${var.tables[count.index]}"
}

# This Crawler is used to extract the right schema from data source
resource "aws_glue_crawler" "initial-crawler" {
  database_name          = aws_glue_catalog_database.initial_database.name
  count                  = length(var.tables)
  name                   = "crawler-${var.tables[count.index]}"
  role                   = var.glue_role_id
  description            = "Get schema about database"

  jdbc_target {
    connection_name = aws_glue_connection.database_connection.name
    path            = var.jdbc_target[count.index]
  }

  tags = {
    Component = "GlueA"
  }
}

# This trigger is used to start the initial crawler
resource "aws_glue_trigger" "crawler-trigger" {
  count         = length(var.tables)
  name          = "trigger-crawler-${var.tables[count.index]}"
  type          = "SCHEDULED"
  schedule      = var.schedules[count.index]
  workflow_name = aws_glue_workflow.workflow-initial-load[count.index].name

  actions {
    crawler_name = aws_glue_crawler.initial-crawler[count.index].name
  }

  tags = {
    Component = "GlueA"
  }
}

# This job is used to extract the initial dump with the right schema
resource "aws_glue_job" "initial-job" {
  count                  = length(var.tables)
  name                   = "initial-job-${var.tables[count.index]}"
  role_arn               = var.glue_role
  connections            = [aws_glue_connection.database_connection.name]
  glue_version           = "2.0"

  command {
    python_version  = 3
    script_location = "s3://name-bucket-scripts/initial_ingestion_with_dump.py"
  }
  worker_type       = "G.1X"
  number_of_workers = "10"
  tags = {
    Component = "GlueA"
  }

  default_arguments = {
    "--S3_SOURCE"        = "s3://name-bucket-transfer/dumps/${var.source_s3[count.index]}"
    "--S3_TARGET"        = "s3://name-bucket-rawzone/${var.tables[count.index]}/"
    "--CRAWLER_DATABASE" = "crawler_database"
    "--CRAWLER_TABLE"    = var.table_crawler[count.index]
  }
}

# This trigger starts the job
resource "aws_glue_trigger" "job-trigger" {
  count         = length(var.tables)
  name          = "trigger-job-${var.tables[count.index]}"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.workflow-initial-load[count.index].name

  actions {
    job_name = aws_glue_job.initial-job[count.index].name
  }

  tags = {
    Component = "GlueA"
  }

  predicate {
    conditions {
      crawler_name = aws_glue_crawler.initial-crawler[count.index].name
      crawl_state  = "SUCCEEDED"
    }
  }
}

# This Crawler extracts the DataLake catalog
resource "aws_glue_crawler" "crawler-catalog" {
  count                  = length(var.tables)
  database_name          = aws_glue_catalog_database.initial_database.name
  name                   = "crawler-rawzone-${var.tables[count.index]}"
  role                   = var.glue_role_id
  description            = "Get schema about s3 parquet database"
  s3_target {
    path = "s3://name-bucket-rawzone/${var.tables[count.index]}/"
  }
  tags = {
    Component = "GlueA"
  }
}

# This trigger starts the crawler catalog
resource "aws_glue_trigger" "trigger-crawler-catalog" {
  count         = length(var.tables)
  name          = "trigger-crawler-rawzone-${var.tables[count.index]}"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.workflow-initial-load[count.index].name

  actions {
    crawler_name = aws_glue_crawler.dbo-s3-crawler-ftcrm[count.index].name
  }

  predicate {
    conditions {
      job_name = aws_glue_job.initial-job[count.index].name
      state    = "SUCCEEDED"
    }
  }
}
