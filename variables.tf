variable "event_rule_name" {
  type        = string
  default     = ""
  description = "The desired name of the CloudWatch event rule."
}

variable "lambda_function_name" {
  type        = string
  default     = ""
  description = "The desired name of the S3 remediation lambda function."
}

variable "lambda_role_name" {
  type        = string
  default     = ""
  description = "The desired IAM role name for the S3 remediation lambda function."
}

variable "resource_prefix" {
  type        = string
  default     = "s3-remediation"
  description = "The name prefix to use for resources provisioned by the module."
}
