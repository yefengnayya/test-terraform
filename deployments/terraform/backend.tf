terraform {
  backend "remote" {
    organization = "nayya"

    workspaces {
      prefix = "test-terraform-"
    }
  }
}