variable "lambda_project_name" {
  default     = ""
  description = "Unique name for the lambda function"
}

variable "region" {
  default = ""

  description = <<EOF
This is the AWS region the lambda function will be deployed to.
It's also used as part of the s3 bucket name.
EOF
}

variable "lambda_bucket" {}

variable "lambda_description" {
  default = ""
}

variable "lambda_runtime" {
  default = "python2.7"
}

variable "lambda_envs" {
  default = {}
  type    = "map"

  description = <<EOF
This map variable sets OS level environment variables that can be utilized by
the lambda function
EOF
}

variable "lambda_schedule_expression" {
  default     = ""
  description = ""
}

variable "graphite_server" {}

variable "lambda_function_policy" {
  default = ""
}

variable "lambda_timeout" {
  default = "120"
}

variable "lambda_subnets" {
  default = []
}

variable "lambda_security_groups" {
  default = []
}

variable "lambda_iam_role" {
  default = ""
}

variable "lambda_memory_size" {
  default = "128"
}
