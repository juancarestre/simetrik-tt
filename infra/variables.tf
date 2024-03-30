variable "aws_profile" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "project_name" {
  type    = string
  default = "simetrik-tt"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "aws_account_id" {
  type = string
}

variable "OPENAI_API_KEY" {
  type = string
}

variable "repository_url" {
  type    = string
  default = "https://github.com/juancarestre/simetrik-tt"
}

variable "AWS_ACCESS_KEY_ID" {
  type      = string
  default   = ""
  sensitive = true
}

variable "AWS_ACCESS_KEY_SECRET" {
  type      = string
  default   = ""
  sensitive = true
}

variable "image_version" {
  type = string
  default = "latest"
}