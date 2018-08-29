locals {
  lambda_project_name = "${replace(var.lambda_project_name, "-", "_")}"
}

locals {
  lambda_root_dir          = "${path.root}//lambda_code/${var.lambda_project_name}"
  lambda_source_dir        = "${local.lambda_root_dir}/source"
  lambda_package_dir       = "${local.lambda_root_dir}/package"
  lambda_build_dir         = "${local.lambda_root_dir}/build"
  lambda_package_file      = "${local.lambda_source_dir}/requirements.txt"
  lambda_handler_code_file = "${local.lambda_source_dir}/${var.lambda_handler_filename}.py"
}

locals {
  lambda_vpc_config = {
    subnet_ids         = ["${var.lambda_subnets}"]
    security_group_ids = ["${var.lambda_security_groups}"]
  }

  default_tags = {}
}

data "aws_caller_identity" "current" {}

resource "null_resource" "lambda_deployment" {
  provisioner "local-exec" "local-build" {
    command = <<EOF
[[ ! -d "${local.lambda_package_dir}" ]] && mkdir -p ${local.lambda_package_dir}
[[ ! -d "${local.lambda_build_dir}" ]] && mkdir -p ${local.lambda_build_dir}

# if this script is invoked remove stale files
rm -fr ${local.lambda_build_dir}/*
[[ -f ${local.lambda_package_dir}/${var.lambda_project_name}.zip ]] && \
rm -f ${local.lambda_package_dir}/${var.lambda_project_name}.zip || true

# if deployment_package.zip file is found then use this as the deployment package
# rather than have the script build one
# this was done to cater for those edge cases when non-linux based compiled
# libraries or executables are used

if [[ -e "${local.lambda_package_dir}/deployment_package.zip" ]]; then
unzip -q ${local.lambda_package_dir}/deployment_package.zip -d ${local.lambda_build_dir}
elif [[ -e "${local.lambda_package_file}" ]]; then
( perl -p -i -e 's/pkg-resource.*\n//g' ${local.lambda_package_file}
pip -q install -r "${local.lambda_package_file}" -t ${local.lambda_build_dir} )
fi

cd ${local.lambda_source_dir} && tar cf - . | (cd ${local.lambda_build_dir} && tar xf -)

EOF

    interpreter = ["bash", "-c"]
  }

  triggers {
    lambda_handler_code_file = "${md5(file(local.lambda_handler_code_file))}"
  }
}

locals {
  null_resource_id = "${join(",",null_resource.lambda_deployment.*.id)}"
  archive_zip_file = "${local.lambda_package_dir}/${local.null_resource_id}-${var.lambda_project_name}.zip"
}

# this block is only necessary because of a
data "null_data_source" "wait_for_lambda_exporter" {
  inputs = {
    source_dir = "${local.lambda_source_dir}"
  }
}

data "archive_file" "lambda_deploy" {
  type        = "zip"
  source_dir  = "${data.null_data_source.wait_for_lambda_exporter.outputs["source_dir"]}/"
  output_path = "${local.archive_zip_file}"
}

resource "aws_iam_policy" "lambda_function_policy" {
  count       = "${var.lambda_function_policy != "" ? 1 : 0}"
  name        = "${local.lambda_project_name}"
  description = "Lambda deployment policy for ${local.lambda_project_name}"
  policy      = "${var.lambda_function_policy}"
}

resource "aws_iam_policy_attachment" "lambda_function_policy" {
  count      = "${var.lambda_function_policy != "" ? 1 : 0}"
  name       = "${local.lambda_project_name}_attachment"
  roles      = ["${aws_iam_role.lambda_iam_role.id}"]
  policy_arn = "${aws_iam_policy.lambda_function_policy.arn}"
}

resource "aws_cloudwatch_event_rule" "lambda_cw_event_rule" {
  count               = "${var.lambda_schedule_expression != "" ? 1 : 0}"
  name                = "${local.lambda_project_name}_scheduled-rule"
  description         = "Scheduled lambda function rule"
  schedule_expression = "${var.lambda_schedule_expression}"
}

resource "aws_cloudwatch_event_target" "lambda_deploy_et_schedule_vpc" {
  count = "${var.lambda_schedule_expression != "" && length(var.lambda_subnets) > 0  ? 1 : 0}"
  rule  = "${aws_cloudwatch_event_rule.lambda_cw_event_rule.name}"
  arn   = "${aws_lambda_function.lambda_deploy_function_vpc.arn}"
}

resource "aws_cloudwatch_event_target" "lambda_deploy_et_schedule" {
  count = "${var.lambda_schedule_expression != "" && length(var.lambda_subnets) == 0  ? 1 : 0}"
  rule  = "${aws_cloudwatch_event_rule.lambda_cw_event_rule.name}"
  arn   = "${aws_lambda_function.lambda_deploy_function.arn}"
}
