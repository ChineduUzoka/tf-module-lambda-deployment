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

variable "lambda_role" {
  default = ""
  description  = <<EOF

EOF
}

variable "lambda_schedule_expression" {
  default     = ""
  description = ""
}

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

variable "lambda_handler_filename" {
  description = "The name of the file that will execute the function - lambda_handler"
  default = "main"
}
# Tag variables
# Tagging variables

variable "costcenter" {
  description = "CostCenter tag (30119 - Thierry Bedos, 30166/30167 - Matt Fryer)"
  type        = "string"
}

variable "dataclassification" {
  description = "DataClassification tag (HighlySensitive, Sensitive, Confidential, Public)"
  type        = "string"
}

variable "environment" {
  description = "Environment tag (Secure, Prod, Corp, Lab, DataWarehouse)"
  type        = "string"
}

variable "launchedby" {
  description = "LaunchedBy tag (e.g. terraform-api)"
  type        = "string"
  default     = "terraform-api"
}

variable "team" {
  description = "Team tag (HCOM_...)"
  type        = "string"
}
