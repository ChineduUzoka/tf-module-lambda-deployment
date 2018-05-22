resource "aws_iam_role" "lambda_iam_role" {
  name        = "lambda_deployment_role_${local.lambda_project_name}"
  description = "Lambda deployment role for ${local.lambda_project_name}"

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
  name        = "lambda_deployment_policy_${local.lambda_project_name}"
  description = "Default lambda policy for ${local.lambda_project_name}"

  policy = "${data.aws_iam_policy_document.lambda_iam_document.json}"
}

data "aws_iam_policy_document" "lambda_iam_document" {
  statement {
    sid = "lambdaCloudWatchDefault"

    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy_attachment" "lambda_iam_attachment" {
  name       = "lambda_deployment_att_${local.lambda_project_name}"
  roles      = ["${aws_iam_role.lambda_iam_role.name}"]
  policy_arn = "${aws_iam_policy.lambda_iam_policy.arn}"
}
