# S3 Public Access Remediation w/ Whitelist

This scenario deploys the necessary AWS configuration to automatically remediated publicly accessible S3 buckets.

```hcl
provider "aws" {}

module "aws_config" {
  source = "github.com/alannix-lw/terraform-s3-remediation"

  bucket_whitelist = "example-bucket-name-1, example-bucket-name-2"
}
```
