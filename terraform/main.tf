terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30"

    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = " ~> 2.25.2"
    }
  }
  backend "s3" {
    bucket         = "llm-inference-api-terraform-state"
    key            = "llm-inference-api/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "llm-inference-api-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.REGION
}



data "terraform_remote_state" "bootstrap" {
  backend = "s3"
  config = {
    bucket = "llm-inference-api-terraform-state"
    key    = "bootstrap/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  artifacts_bucket_name = coalesce(
    var.artifacts_bucket_name,
    data.terraform_remote_state.bootstrap.outputs.ci_artifacts_bucket_name
  )
}