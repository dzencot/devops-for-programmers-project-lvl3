terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "example-org-671cd6"

    workspaces {
      name = "hexlet-project3"
    }
  }
}
