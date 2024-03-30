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


variable "AWS_ACCESS_KEY_ID" {
  type = string
  sensitive = true
}

variable "AWS_ACCESS_KEY_SECRET" {
  type = string
  sensitive = true
}

variable "aws_profile" {
  type = string
}

variable "OPENAI_API_KEY" {
  type = string
  sensitive = true
}