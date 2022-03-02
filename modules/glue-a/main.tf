
/*
Main file for configurations default for Glue process, like database connnections, database catalog, etc;
*/ 

resource "aws_glue_connection" "database_connection" {
  name = "connection-database"

  connection_type = "JDBC"

  physical_connection_requirements {
    availability_zone      = var.availability_zone[var.env]
    security_group_id_list = ["${var.glue_sql_security_group[var.env]}", var.glue_security_group_id]
    subnet_id              = var.subnet[var.env]
  }


  connection_properties = {
    JDBC_CONNECTION_URL = "${var.string_connection[var.env]}"
    USERNAME            = var.jdbc_user
    PASSWORD            = var.jdbc_pass
  }

}

# catalog database 

resource "aws_glue_catalog_database" "catalog_database" {
  name = "database-catalog"
}

resource "aws_glue_catalog_database" "raw_database" {
  name = "database-raw"
}

