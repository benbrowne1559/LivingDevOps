terraform {

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

  assume_role {
    # The ARN of the role you want the CLI to assume
    role_arn = "arn:aws:iam::628132821277:role/2Tier-WebApp-Terraform"

    # Optional: A session name for CloudTrail logs
    session_name = "TerraformSesh"
  }
}
