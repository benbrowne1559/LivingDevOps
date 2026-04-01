terraform {

  required_version = "~> 1.14"

  cloud {
    organization = "benbrowne_org"
    workspaces {
      name = "2Tier-WebApp"
    }
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region

}
