provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "slim_cd_bucket" {
  bucket = "slim-cd-bucket"
  acl    = "private"
}

resource "aws_lambda_function" "slim_cd_lambda" {
  function_name    = "slim_cd_function"
  role            = aws_iam_role.lambda_role.arn
  runtime         = "python3.8"
  handler         = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("lambda_function.zip")
}
