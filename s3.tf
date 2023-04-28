resource "aws_s3_bucket" "catalog_bucket" {
  bucket = var.bucket_name

  tags = {
    name = "catalog"
    env  = "dev"
  }
}

resource "aws_iam_policy" "policys3" {
  name        = "policy-s3"
  description = "My test policy"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.catalog_bucket.arn}"
    },
    {
      "Action": [
        "s3:GetObject", 
        "s3:PutObject", 
        "s3:DeleteObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.catalog_bucket.arn}/apps"
    }
  ]

}
EOT
}