resource "random_string" "suffix" {
  length           = 5
  special          = false
  upper            = false
}

resource "aws_s3_bucket" "lambda" {
  bucket = "${lower(var.user_information.name)}-lambda-sources-${random_string.suffix.result}"
  tags = {
    Name        = var.user_information.name
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "lambda" {
  bucket = aws_s3_bucket.lambda.id
  acl    = "private"
}

resource "aws_s3_object" "chanify-nasa-lambda-sourcefile" {
  bucket = aws_s3_bucket.lambda.bucket
  key    = "chanify-nasa-send.zip"
  source = "../backend/lambda/out/chanify-nasa-send.zip"
}

resource "aws_cloudwatch_event_rule" "daily" {
  name = "daily-cron"
  schedule_expression = "cron(0 10 * * ? *)" # every day at 10:00am UTC
}

resource "aws_cloudwatch_event_target" "run-daily" {
    rule = aws_cloudwatch_event_rule.daily.name
    target_id = "run-daily"
    arn = aws_lambda_function.chanify-nasa-send.arn
}

resource "aws_lambda_permission" "cloudwatch-trigger-chanify" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.chanify-nasa-send.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.daily.arn
}

data "aws_iam_policy_document" "chanify-iam-lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "chanify-iam-lambda" {
  name = "chanify-nasa-send-lambda"
  description =  "chanify-nasa-send lambda execution role"
  assume_role_policy = data.aws_iam_policy_document.chanify-iam-lambda.json
}

resource "aws_lambda_function" "chanify-nasa-send" {
    function_name = "chanify-nasa-send"
    role          = aws_iam_role.chanify-iam-lambda.arn
    handler       = "handler.chanifyHandler"
    runtime       = "nodejs18.x"
    s3_bucket     = aws_s3_bucket.lambda.bucket
    s3_key        = aws_s3_object.chanify-nasa-lambda-sourcefile.id
    environment {
      variables = {
        "CHANIFY_TOKEN" = var.CHANIFY_TOKEN
        "NASA_API_KEY" = var.NASA_API_KEY
      }
    }
}