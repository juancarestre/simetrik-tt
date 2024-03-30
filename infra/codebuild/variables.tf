variable "project_name" {
  type = string
}

variable "project_env" {
  type = string
}

variable "account_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "repository_url" {
  type = string
}

variable "environment_variables" {
    type = list(object({
      name = string
      value = string
    }))
}