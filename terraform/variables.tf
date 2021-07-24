variable "aws_key_name" {}

variable "ssh_pub_key" {}


variable "access_key" {
  default = ""
  sensitive = true
}

variable "secret_key" {
  default = ""
  sensitive = true
}

variable "datadog_api_key" {}

variable "datadog_app_key" {}
