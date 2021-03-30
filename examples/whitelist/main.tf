provider "aws" {}

module "s3_remediation" {
  source = "../../"

  bucket_whitelist = "example-bucket-name-1, example-bucket-name-2"
}
