terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  # backend "s3" {
  # bucket = "cliack-app-terraform-backend"
  #   key = "click-app/terraform.tfstate"
  #   region = "us-west-2"
  # }
}

provider "aws" {
  region = var.aws_region
}