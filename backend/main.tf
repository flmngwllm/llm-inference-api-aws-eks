provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "llm-inference-api-terraform-state"
    key            = "bootstrap/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "llm-inference-api-terraform-locks"
    encrypt        = true
  }
}



