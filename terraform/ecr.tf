resource "aws_ecr_repository" "app_repository" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "AppECRRepository"
  }
}

resource "aws_ecr_lifecycle_policy" "untagged_cleanup" {
  repository = aws_ecr_repository.app_repository.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images at next day"
        selection    = {
          tagStatus     = "untagged"
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}