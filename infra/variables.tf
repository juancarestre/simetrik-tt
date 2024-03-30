variable "aws_profile" {
  type        = string
  description = "AWS profile to use for authentication."
}

variable "aws_account_id" {
  type        = string
  description = "ID of the AWS account where resources will be deployed."
}

variable "OPENAI_API_KEY" {
  type        = string
  sensitive   = true
  description = "OpenAI API key for accessing AI services."
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region where resources will be created if not specified otherwise."
}

variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC network."
}

variable "project_name" {
  type        = string
  default     = "simetrik-tt"
  description = "Name of the project."
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment in which resources will be deployed."
}

variable "repository_url" {
  type        = string
  default     = "https://github.com/juancarestre/simetrik-tt"
  description = "URL of the project's repository."
}

variable "AWS_ACCESS_KEY_ID" {
  type        = string
  default     = ""
  sensitive   = true
  description = "AWS access key ID."
}

variable "AWS_ACCESS_KEY_SECRET" {
  type        = string
  default     = ""
  sensitive   = true
  description = "AWS access key secret."
}

variable "image_version" {
  type        = string
  default     = "latest"
  description = "Version of the container image to use."
}

variable "force_image_rebuild" {
  type        = bool
  default     = false
  description = "Indicates whether the container image should be rebuilt even if there are no changes in the source code."
}
