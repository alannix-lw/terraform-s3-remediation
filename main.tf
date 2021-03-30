locals {
  lambda_function_name = length(var.lambda_function_name) > 0 ? var.lambda_function_name : "${var.resource_prefix}-function-${random_id.uniq.hex}"
  lambda_role_name     = length(var.lambda_role_name) > 0 ? var.lambda_role_name : "${var.resource_prefix}-lambda-role-${random_id.uniq.hex}"
  event_rule_name      = length(var.event_rule_name) > 0 ? var.event_rule_name : "${var.resource_prefix}-event-rule-${random_id.uniq.hex}"
}

resource "random_id" "uniq" {
  byte_length = 4
}

# Create an event rule for events that cause changes to S3
resource "aws_cloudwatch_event_rule" "s3_events" {
  name        = local.event_rule_name
  description = "A rule pertaining to S3 events that change ACLs or Bucket Policies"
  # event_bus_name = aws_cloudwatch_event_bus.s3_events.name

  event_pattern = <<EOF
{
  "source": ["aws.s3"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["s3.amazonaws.com"],
    "eventName": [
      "PutBucketAcl",
      "PutBucketPolicy"
    ]
  }
}
EOF
}

# Set the EventBridge target as the Lambda function
resource "aws_cloudwatch_event_target" "s3_events" {
  # event_bus_name = aws_cloudwatch_event_bus.s3_events.name
  rule = aws_cloudwatch_event_rule.s3_events.name
  arn  = aws_lambda_function.s3_event_handler.arn
}

# Create a Lambda Function for handling the S3 events
resource "aws_lambda_function" "s3_event_handler" {
  function_name = local.lambda_function_name

  filename         = data.archive_file.lambda_app.output_path
  source_code_hash = data.archive_file.lambda_app.output_base64sha256

  handler = "s3_remediation.lambda_handler"
  runtime = "python3.8"

  role = aws_iam_role.lambda_execution.arn

  environment {
    variables = {
      S3_WHITELIST = var.bucket_whitelist
    }
  }
}

# Allow EventBridge to trigger the Lambda
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_event_handler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_events.arn
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "lambda_execution" {
  name = local.lambda_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Allow the Lambda Function to write logs
resource "aws_iam_role_policy" "lambda_log_policy" {
  name = "s3_remediation_log_access"
  role = aws_iam_role.lambda_execution.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*",
      "Sid": "LambdaAccessLogs"
    }
  ]
}
EOF
}

# Allow the Lambda Function to change S3
resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "s3_remediation_s3_access"
  role = aws_iam_role.lambda_execution.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetBucketAcl",
        "s3:PutBucketAcl",
        "s3:PutBucketPolicy"
      ],
      "Effect": "Allow",
      "Resource": "*",
      "Sid": "LambdaAccessS3"
    }
  ]
}
EOF
}

# Zip the code for creating the Lambda Function
data "archive_file" "lambda_app" {
  type        = "zip"
  output_path = "${path.module}/tmp/lambda_app.zip"
  source_dir  = "${path.module}/lambda/"
  excludes    = ["tests"]
}
