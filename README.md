# hcom-terraform-module-lambda-deployment
## Module Parameters
| Variable      | Required          | Default   | Description |
| --------------| :---------------: | :---------|------------------------------|
| region | yes | us-west-2 | The name of the AWS region used to deploy lambda function |
| profile | yes | | The AWS security authentication profile used |
| environment | yes | | HCOMs environment |
| lambda_project_name | yes | | This variable is used to name the function and is also used to name a number of resources created by this module|
| lambda_runtime | yes | python2.7 | Only python2.7 and python3.6 are supportable runtime environments |
| lambda_envs | no | | A map of shell environment variables to be used by lambda funtion |
| lambda_role | no | | AWS IAM lambda role |
| lambda_schedule_expression | no | | Cron or Rate formatted schedule |
| lambda_function_policy | yes | | AWS IAM lambda policy|
| lambda_timeout | no | 120 | Maximum number of seconds that lambda function will run for until terminated|
| lambda_subnets | no | | Allow lambda to access resources from within a VPC |
| lambda_security_groups | no | | A list of one or more security groups |
| lambda_memory_size | no | 128 | Memory value in MB's|
| default-tags | no | | A mapping of tags used to tag this modules taggable resources|
### Default AWS Lambda Resources Deployed
The following resources are deployed for each AWS Lambda function that is deployed from this module


## Pre-requisites
At this time only Python is supported.
### Requirements
* Terraform 0.10.x
* Terragrunt v0.13.x
* Virtualenv or virtualenvwrapper

This project must be run within a Python virtualenv environment
#### Create a python virtualenv:
1. Install virtualenv or virtualenvwrapper. This normally involves installing pip first then using pip to install _virtualenv_ or _virtualenvwrapper_

2. Create a virtualenv environment (call it terra it doesn't matter what you call except that you make it descriptive) and activate it.
```
mkdir $HOME/virtualenv
cd $HOME/virtualenv
virtualenv terra
$HOME/virtualenv/terr/bin/activate
```

## Lambda deployment
To deploy a lambda function the following directory structure is needed.
As in the example below your lambda function must be kept copied to the source directory
```
{TOP}/module/lambda/lambda_code/source/main.py
{TOP}/module/lambda/lambda_code/source/requirements.txt <- optional
```

## Run

```
cd live/lab-secure
AWS_PROFILE=hcom-lab-secure terragrunt init
AWS_PROFILE=hcom-lab-secure terragrunt plan
AWS_PROFILE=hcom-lab-secure terragrunt apply
```

## Example
This example shows how to deploy a lambda function in a VPC
```
module "great_lambda_function" {
   source                  = "git::ssh://git@stash.hcom:7999/awsinfra/hcom-terraform-module-lambda-deployment.git//aws/modules/lambda_deployment"

   lambda_project_name     = "great_lambda_function"
   lambda_description      = "This function is Greate Lambda Function and does amazing things"
   lambda_handler_filename = "great_lambda_function"
   lambda_handler_filename = "great_lambda_function"
   lambda_function_policy  = "${data.aws_iam_policy_document.lambda.json}"
   lambda_security_groups  = ["wonderfully_secure_security_group"]
   lambda_memory_size      = 512

   region                  = "us-west-2"
   lambda_envs             =  "${data.null_data_source.lambda_envs.inputs}"

   default-tags            = "${module.hcom-tags.tags}"
}
```
