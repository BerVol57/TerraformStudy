provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "eu-central-1"
  s3_use_path_style           = false
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = false

  endpoints {
    cloudwatch = "http://localhost:4566"
    lambda     = "http://localhost:4566"
    s3         = "http://s3.localhost.localstack.cloud:4566"
    iam        = "http://localhost:4566"
  }
}

# s3_start
resource "aws_s3_bucket" "s3_start" {
  bucket = "s3-start"

}

resource "aws_s3_bucket_lifecycle_configuration" "cleanup" {
  bucket = aws_s3_bucket.s3_start.id

  rule {
    expiration {
      days = 1
    }
    id     = "cleanup-rule"
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "s3_start_acl" {
  bucket = aws_s3_bucket.s3_start.id
  acl    = "private"
}

# s3_finish
resource "aws_s3_bucket" "s3_finish" {
  bucket = "s3-finish"
}

# for copy files by lambda
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3_start.arn
}

resource "aws_lambda_function" "func" {
  filename      = "lambda-copy.zip" ####################################################################
  function_name = "lambda-copy"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "exports.example"
  runtime       = "go1.x"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.s3_start.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.func.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "AWSLogs/"
    filter_suffix       = ".log"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}