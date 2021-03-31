variable "bucket_whitelist" {
  type        = string
  default     = ""
  description = "A comma separated list of bucket names to whitelist from remediation"
}

variable "event_rule_name" {
  type        = string
  default     = ""
  description = "The desired name of the CloudWatch event rule"
}

variable "lambda_function_name" {
  type        = string
  default     = ""
  description = "The desired name of the S3 remediation lambda function"
}

variable "lambda_role_name" {
  type        = string
  default     = ""
  description = "The desired IAM role name for the S3 remediation lambda function"
}

variable "lambda_tracing_mode" {
  type        = string
  default     = "PassThrough"
  description = "The desired tracing mode for the lambda function"
}

variable "resource_prefix" {
  type        = string
  default     = "s3-remediation"
  description = "The name prefix to use for resources provisioned by the module"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to be assigned to created resources"
  default     = {}
}
