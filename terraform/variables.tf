variable "number_of_instances" {
  type = string
  default = 2
}
variable "aws_key_name" {
  type = string
  default = ""
}

variable "ssh_pub_key" {
  type = string
  default = ""
}


variable "access_key" {
  type = string
  default   = ""
  sensitive = true
}

variable "secret_key" {
  type = string
  default   = ""
  sensitive = true
}

variable "datadog_api_key" {
  type = string
  default = ""
  sensitive = true
}

variable "datadog_app_key" {
  type = string
  default = ""
  sensitive = true
}
