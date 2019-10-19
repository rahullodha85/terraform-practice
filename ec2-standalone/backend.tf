terraform {
  backend "s3" {
    bucket = "rogue-bucket"
    key    = "terraform/ec2-standalone"
    region = "us-east-1"
  }
}

