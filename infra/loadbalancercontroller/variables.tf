variable "aws_region" {
  type        = string
  description = "The AWS region where resources will be deployed."
}

variable "environment" {
  type        = string
  description = "The environment in which the resources will be provisioned (e.g., 'dev', 'test', 'prod')."
}

variable "cluster_name" {
  type        = string
  description = "The name of the Amazon EKS cluster."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the Amazon VPC (Virtual Private Cloud) where the resources will be provisioned."
}

variable "oidc_provider_arn" {
  type        = string
  description = "The Amazon Resource Name (ARN) of the OIDC (OpenID Connect) provider associated with the EKS cluster."
}
