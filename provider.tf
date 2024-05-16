terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

}

provider "aws" {
  region                   = var.region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
  default_tags {
    tags = {
      Environment = var.tag_environment
      Project     = var.tag_project
    }

  }

}