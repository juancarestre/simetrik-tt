variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cidr_block" {
  type = string
}

variable "count_private_subnet" {
  type = number
}

variable "count_public_subnet" {
  type = number
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "eks_cluster_name" {
  type = string
  default = "no_cluster"
}