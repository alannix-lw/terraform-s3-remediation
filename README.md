# S3 Public Access Remediation

[![HIPAA](https://app.soluble.cloud/api/v1/public/badges/74e08c80-4614-4030-bd1d-e2aa006f7cbd.svg)](https://app.soluble.cloud/repos/details/github.com/alannix-lw/terraform-s3-remediation)  [![CIS](https://app.soluble.cloud/api/v1/public/badges/fc0cda5a-b51b-4973-9a41-eebfd42b33b6.svg)](https://app.soluble.cloud/repos/details/github.com/alannix-lw/terraform-s3-remediation)  [![IaC](https://app.soluble.cloud/api/v1/public/badges/ec7efc21-04b5-4e9e-ad59-c90014c2eed2.svg)](https://app.soluble.cloud/repos/details/github.com/alannix-lw/terraform-s3-remediation)  

## Description

A Terraform Module to implement monitoring of 'PutBucketAcl' and 'PutBucketPolicy' API calls to validate that changes aren't publicly exposing S3 objects.

This module will implement a CloudWatch rule which triggers a Lambda function when changes are made to an S3 Bucket's Policy or ACLs. The Lambda function will examine the Policy and/or ACLs based on the type of call that was made, and remove any public access that was given.

## Inputs

| Name                 | Description                                                                  | Type          | Default          |
| -------------------- | ---------------------------------------------------------------------------- | ------------- | ---------------- |
| bucket_whitelist     | A comma separated list of bucket names to whitelist from remediation         | `string`      | ""               |
| event_rule_name      | The desired name of the CloudWatch event rule                                | `string`      | ""               |
| lambda_function_name | The desired name of the S3 remediation lambda function                       | `string`      | ""               |
| lambda_role_name     | The desired IAM role name for the S3 remediation lambda function             | `string`      | ""               |
| lambda_tracing_mode  | The desired tracing mode for the lambda function ("Active" or "PassThrough") | `string`      | "PassThrough"    |
| resource_prefix      | The name prefix to use for resources provisioned by the module               | `string`      | "s3-remediation" |
| tags                 | A map of tags to be assigned to created resources                            | `map(string)` | `{}`             |

## Outputs

| Name                | Description                                         |
| ------------------- | --------------------------------------------------- |
| cloudwatch_rule_arn | ARN of the created CloudWatch rule                  |
| lambda_function_arn | ARN of the created Lambda function                  |
| lambda_role_arn     | ARN of the created IAM Role for the Lambda function |
