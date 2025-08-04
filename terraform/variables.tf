variable "REGION" {
    description = "AWS region for resources"
    default = "us-east- 1"
}


variable "public_subnets" {
  description = "Map of public subnets"
  type        = map(number)
  default = {
    "us-east-1a" = 1
    "us-east-1b" = 2
  }
}

variable "private_subnets" {
  description = "Map of private subnets"
  type        = map(number)
  default = {
    "us-east-1a" = 3
    "us-east-1b" = 4
  }
}