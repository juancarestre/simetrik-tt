variable "aws_region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block for the VPC (Virtual Private Cloud)."
  type        = string
}

variable "count_private_subnet" {
  description = "The count of private subnets to be created."
  type        = number
}

variable "count_public_subnet" {
  description = "The count of public subnets to be created."
  type        = number
}

variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The environment in which the resources will be deployed (e.g., dev, staging, prod)."
  type        = string
}

variable "eks_cluster_name" {
  description = "The name of the Amazon EKS cluster. If not provided, 'no_cluster' is used as the default value."
  type        = string
  default     = "no_cluster"
}
