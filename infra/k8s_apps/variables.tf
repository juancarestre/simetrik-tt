variable "app_name" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "aws_region" {
    type = string
}

variable "aws_account_id" {
  type = string
}

variable "container_port" {
  type = number
}

variable "force_image_rebuild" {
  type    = bool
  default = false
}

variable "command" {
  type = list(string)
}

variable "image_version" {
  type = string
  default = "latest"
}


variable "app_path" {
  type = string
}