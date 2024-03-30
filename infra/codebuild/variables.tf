variable "project_name" {
  type        = string
  description = "Name of the project."
}

variable "project_env" {
  type        = string
  description = "Environment of the project (e.g., development, staging, production)."
}

variable "account_id" {
  type        = string
  description = "ID of the AWS account where resources will be deployed."
}

variable "aws_region" {
  type        = string
  description = "AWS region where resources will be created."
}

variable "repository_url" {
  type        = string
  description = "URL of the project's repository."
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "List of environment variables to be passed to the application, specified as a list of objects with 'name' and 'value' attributes."
}
