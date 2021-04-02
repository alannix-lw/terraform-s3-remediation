# Default S3 Public Access Remediation

This scenario deploys the necessary AWS configuration to automatically remediated publicly accessible S3 buckets.

```hcl
provider "aws" {}

module "s3_remediation" {
  source = "github.com/alannix-lw/terraform-s3-remediation"
}
```
