variable "aws_profile" {
  type = string
}

variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "project_name" {
  type = string
  default = "simetrik-tt"
}

variable "environment" {
  type = string
  default = "dev"
}

variable "aws_account_id" {
  type = string
}