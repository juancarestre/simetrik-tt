variable "eks_cluster_name" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "cluster_version" {
  type = string
}

variable "authentication_mode" {
  type    = string
  default = "API_AND_CONFIG_MAP"
}

variable "capacity_type" {
  type    = string
  default = "SPOT"
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_scaling_config" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
}

variable "bootstrap_creator_admin_access" {
  type    = bool
  default = true
}

variable "aws_region" {
  type = string
}