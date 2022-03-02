variable "env" {
  description = "env: dev or prod"
}

variable "region" {
  type = map(string)

  default = {
    "dev"  = "us-east-1"
    "prod" = "us-east-2"
  }

}
