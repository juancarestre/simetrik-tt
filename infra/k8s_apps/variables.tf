variable "app_name" {
  type        = string
  description = "Name of the application."
}

variable "aws_profile" {
  type        = string
  description = "AWS profile to use for authentication."
}

variable "aws_region" {
  type        = string
  description = "AWS region where resources will be deployed."
}

variable "aws_account_id" {
  type        = string
  description = "ID of the AWS account where resources will be deployed."
}

variable "container_port" {
  type        = number
  description = "Port on which the container listens for incoming traffic."
}

variable "force_image_rebuild" {
  type        = bool
  default     = false
  description = "Flag indicating whether to force a rebuild of the container image."
}

variable "command" {
  type        = list(string)
  description = "Command to run inside the container."
}

variable "image_version" {
  type        = string
  default     = "latest"
  description = "Version of the container image to deploy."
}

variable "app_path" {
  type        = string
  description = "Path to the application code."
}

variable "create_ingress" {
  type        = bool
  description = "Flag indicating whether to create an ingress for the application."
}

variable "envs" {
  type = list(object({
    name  = string,
    value = string
  }))
  description = "List of environment variables to be passed to the application."
}
