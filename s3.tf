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

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.catalog-writer.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.catalog_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.catalog_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.catalog-writer.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".png"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
