resource "aws_ecr_repository" "llm_inference_api_repo" {
  name                 = "llm-inference-api"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "llm-inference-api-ecr"
  }
}