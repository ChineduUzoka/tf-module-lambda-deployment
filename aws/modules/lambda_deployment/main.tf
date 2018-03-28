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

if [[ -e "${local.lambda_package_dir}/deployment_package.zip" ]]; then
unzip -q ${local.lambda_package_dir}/deployment_package.zip -d ${local.lambda_build_dir}
elif [[ -e "${local.lambda_package_file}" ]]; then
( perl -p -i -e 's/pkg-resource.*\n//g' ${local.lambda_package_file}
pip -q install -r "${local.lambda_package_file}" -t ${local.lambda_build_dir} )
fi

cd ${local.lambda_source_dir} && tar cf - . | (cd ${local.lambda_build_dir} && tar xf -)
[[ -f ${local.lambda_package_dir}/${var.lambda_project_name}.zip ]] && \
rm -f ${local.lambda_package_dir}/${var.lambda_project_name}.zip || true
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

data "archive_file" "lambda_deploy" {
  type        = "zip"
  source_dir  = "${local.lambda_build_dir}/"
  output_path = "${local.archive_zip_file}"
  depends_on  = ["null_resource.lambda_deployment"]
}

resource "aws_iam_policy" "lambda_function_policy" {
  count       = "${var.lambda_function_policy != "" ? 1 : 0}"
  name = "${var.lambda_project_name}"
  description = "Lambda deployment policy for ${var.lambda_project_name}"
  policy      = "${var.lambda_function_policy}"
}

data "aws_iam_role" "lambda_deploy" {
  name = "${var.lambda_project_name}_lambda_deploy_role"
}

resource "aws_iam_policy_attachment" "lambda_function_policy" {
  count      = "${var.lambda_function_policy != "" ? 1 : 0}"
  name       = "${var.lambda_project_name}-attachment"
  roles      = ["${aws_iam_role.lambda_iam_role.id}"]
  policy_arn = "${aws_iam_policy.lambda_function_policy.arn}"
}

resource "aws_cloudwatch_event_rule" "lambda_deploy_er" {
  count               = "${var.lambda_schedule_expression != "" ? 1 : 0}"
  name                = "${var.lambda_project_name}-scheduled-rule"
  description         = "Scheduled lambda function rule"
  schedule_expression = "${var.lambda_schedule_expression}"
}
