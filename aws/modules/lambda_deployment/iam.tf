resource "aws_iam_role" "iam_lambda_for_deploy" {
  name_prefix = "${var.lambda_project_name}"

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

resource "aws_iam_policy" "lambda_default_policy" {
  name = "lambda_deploy_${var.lambda_project_name}"
  description = "Lambda default policy for ${var.lambda_project_name}"

  policy      = "${data.aws_iam_policy_document.lambda_default_policy_doc.json}"

}

data "aws_iam_policy_document" "lambda_default_policy_doc" {
  statement {
    sid       = "lambdaDeploydDefault"

    effect    = "Allow"

    actions   = [
      "lambda:InvokeFunction",
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

resource "aws_iam_policy_attachment" "lambda_default_policy" {
  name       = "lambda_deploy_policy"
  roles      = ["${aws_iam_role.iam_lambda_for_deploy.name}"]
  policy_arn = "${aws_iam_policy.lambda_default_policy.arn}"
}
