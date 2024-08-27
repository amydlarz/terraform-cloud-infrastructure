resource "aws_s3_bucket" "web_storage" {
  bucket_prefix = "web-app-storage"
  tags          = {
    Name = "web-app-storage"
  }
}

resource "aws_iam_role" "access_to_bucket_role" {
  name = "access-to-bucket-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_policy" "ecs_s3_policy" {
  name        = "ecs-s3-access-policy"
  description = "Allow ECS tasks to access the S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
        ],
        Resource = "${aws_s3_bucket.web_storage.arn}/*",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "ecs_s3_policy_attachment" {
  policy_arn = aws_iam_policy.ecs_s3_policy.arn
  role     = aws_iam_role.access_to_bucket_role.name
}
