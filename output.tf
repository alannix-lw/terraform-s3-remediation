output "cloudwatch_rule_arn" {
  description = "ARN of the created CloudWatch rule"
  value       = aws_cloudwatch_event_rule.s3_events.arn
}

output "lambda_function_arn" {
  description = "ARN of the created Lambda function"
  value       = aws_lambda_function.s3_event_handler.arn
}

output "lambda_role_arn" {
  description = "ARN of the created IAM Role for the Lambda function"
  value       = aws_iam_role.lambda_execution.arn
}
