resource "aws_lambda_function" "catalog-writer" {
  // If the file is not in the current working directory you will need to include a
  // path.module in the filename.
  filename      = "catalog-code.zip"
  function_name = "catalog-code"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "code.lambda_handler"

  source_code_hash = filebase64sha256("catalog-code.zip")

  runtime = "python3.9"
}

 data "aws_iam_policy_document" "inline_policy" {
  statement {
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:ListTables",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:UpdateItem",
      "dynamodb:UpdateTable",
    ]

    resources = [aws_dynamodb_table.basic-dynamodb-table.arn]

    effect = "Allow"
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "lambda-role"

  inline_policy {
    name   = "policy-dynamodb-writer"
    policy = data.aws_iam_policy_document.inline_policy.json
  }

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}