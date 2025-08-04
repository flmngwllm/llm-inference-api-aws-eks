terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.30"

        }
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = " ~> 2.25.2"
        }
    }
}

provider "aws" {
    region = var.REGION
}