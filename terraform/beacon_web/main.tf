resource "aws_s3_bucket" "ins" {
  arn            = "arn:aws:s3:::ins.acme-dev.example"
  bucket         = "ins.acme-dev.example"
  force_destroy  = "false"
  hosted_zone_id = "Z0EXAMPLE0003"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": "s3:GetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Resource": "arn:aws:s3:::ins.acme-dev.example/*",
      "Sid": "PublicReadGetObject"
    },
    {
      "Action": "s3:GetObject",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E0EXAMPLE00001"
      },
      "Resource": "arn:aws:s3:::ins.acme-dev.example/*",
      "Sid": "2"
    },
    {
      "Action": "s3:GetObject",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E0EXAMPLE00001"
      },
      "Resource": "arn:aws:s3:::ins.acme-dev.example/*",
      "Sid": "3"
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  request_payer = "BucketOwner"

  versioning {
    enabled    = "false"
    mfa_delete = "false"
  }

  website {
    index_document = "index.html"
  }

  website_domain   = "s3-website.ap-northeast-2.amazonaws.com"
  website_endpoint = "ins.acme-dev.example.s3-website.ap-northeast-2.amazonaws.com"
}