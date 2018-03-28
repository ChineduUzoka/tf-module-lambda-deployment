resource "aws_iam_role" "lambda_iam_role" {
  name = "lambda-deployment-for-${var.lambda_project_name}"
  description = "This is the default role assigned to a lambda deployment function from hcom-terraform-module-lambda-deployment"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_iam_policy" {
  name = "lambda-deployment-for-${var.lambda_project_name}"
  description = "Default lambda policy for hcom-terraform-module-lambda-deployment"

  policy      = "${data.aws_iam_policy_document.lambda_iam_document.json}"

}

data "aws_iam_policy_document" "lambda_iam_document" {
  statement {
    sid       = "lambdaCloudWatchDefault"

    effect    = "Allow"

    actions   = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]

    resources = [
      "*"
    ]
  }    
}

resource "aws_iam_policy_attachment" "lambda_iam_attachment" {
  name       = "lambda-deployment-att-for-${var.lambda_project_name}"
  roles      = ["${aws_iam_role.lambda_iam_role.name}"]
  policy_arn = "${aws_iam_policy.lambda_iam_policy.arn}"
}
