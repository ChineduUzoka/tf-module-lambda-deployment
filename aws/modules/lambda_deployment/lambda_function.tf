# VPC lambda function
resource "aws_lambda_function" "lambda_deploy_function_vpc" {
  count             = "${length(var.lambda_subnets) > 0 ? 1 : 0}"
  filename          = "${data.archive_file.lambda_deploy.output_path}"
  function_name     = "${local.lambda_project_name}"
  handler           = "${var.lambda_handler_filename}.lambda_handler"
  description       = "${var.lambda_description}"
  role              = "${aws_iam_role.lambda_iam_role.arn}"
  source_code_hash  = "${data.archive_file.lambda_deploy.output_base64sha256}"
  runtime           = "${var.lambda_runtime}"
  timeout           = "${var.lambda_timeout}"
  memory_size       = "${var.lambda_memory_size}"

  vpc_config {
    subnet_ids         = [ "${var.lambda_subnets}" ]
    security_group_ids = [ "${var.lambda_security_groups}" ]
  }

  environment {
    variables = "${var.lambda_envs}"
  }

  lifecycle {
    ignore_changes = ["source_code_hash","last_modified"]
  }

  tags = "${merge(var.default-tags,
                 map("Name", "${local.lambda_project_name}"),
                 map("Application", "Lambda"))
         }"

}

resource "aws_lambda_alias" "lambda_deploy_alias_vpc" {
  count            = "${length(var.lambda_subnets) > 0 ? 1 : 0}"
  name             = "${local.lambda_project_name}"
  description      = "${var.lambda_description}"
  function_name    = "${aws_lambda_function.lambda_deploy_function_vpc.arn}"
  function_version = "$LATEST"
}

resource "aws_lambda_permission" "allow_cw_er_vpc" {
  count         = "${var.lambda_schedule_expression != "" && length(var.lambda_subnets) > 0  ? 1 : 0}"
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_deploy_function_vpc.arn}"
  principal     = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.lambda_cw_event_rule.arn}"
  qualifier     = "${aws_lambda_alias.lambda_deploy_alias.name}"
}

# Non VPC lambda function
resource "aws_lambda_function" "lambda_deploy_function" {
  count             = "${length(var.lambda_subnets) == 0 ? 1 : 0}"
  filename          = "${data.archive_file.lambda_deploy.output_path}"
  function_name     = "${local.lambda_project_name}"
  handler           = "${var.lambda_handler_filename}.lambda_handler"
  description       = "${var.lambda_description}"
  role              = "${aws_iam_role.lambda_iam_role.arn}"
  source_code_hash  = "${data.archive_file.lambda_deploy.output_base64sha256}"
  runtime           = "${var.lambda_runtime}"
  timeout           = "${var.lambda_timeout}"
  memory_size       = "${var.lambda_memory_size}"

  environment {
    variables = "${var.lambda_envs}"
  }
  #
  # lifecycle {
  #   ignore_changes = ["source_code_hash","last_modified"]
  # }

  tags = "${merge(var.default-tags,
                 map("Name", "${local.lambda_project_name}"),
                 map("Application", "Lambda"))
         }"

}

resource "aws_lambda_alias" "lambda_deploy_alias" {
  count            = "${length(var.lambda_subnets) == 0 ? 1 : 0}"
  name             = "${local.lambda_project_name}"
  description      = "${var.lambda_description}"
  function_name    = "${aws_lambda_function.lambda_deploy_function.function_name}"
  function_version = "$LATEST"
}

resource "aws_lambda_permission" "allow_cw_er" {
  count = "${var.lambda_schedule_expression != "" && length(var.lambda_subnets) == 0  ? 1 : 0}"
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_deploy_function.arn}"
  principal     = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.lambda_cw_event_rule.arn}"
}
