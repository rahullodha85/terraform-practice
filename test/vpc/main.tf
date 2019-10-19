module "vpc" {
  source = "./../../vpc"
}

terraform {
  backend "s3" {
    bucket = "rogue-bucket"
    key    = "terraform/vpc"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

