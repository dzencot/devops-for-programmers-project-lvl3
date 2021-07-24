terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

provider "aws" {
  region                  = "eu-central-1"
  shared_credentials_file = "./.aws/creds"
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.datadoghq.eu/"
}
