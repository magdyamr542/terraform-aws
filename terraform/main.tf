terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "2.4.0"
    }

  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "eu-central-1"
  profile = "private"
}


provider "archive" {
}
