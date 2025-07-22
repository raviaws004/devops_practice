terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.3.0"
    }
  }

  backend "s3" {
    bucket = "raviaws007-tf-remote-state"
    key    = "foreach"
    region = "us-east-1"
    dynamodb_table = "raviaws007-tf-state-locking"
}
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}


