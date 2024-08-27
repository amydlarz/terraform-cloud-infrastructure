terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.64.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }

  backend "s3" {
    bucket  = "terraform-state-062354364563"
    key     = "terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }
}
