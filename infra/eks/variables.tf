variable "eks_cluster_name" {
  type        = string
  description = "Name of the Amazon EKS cluster."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of IDs of private subnets where the EKS worker nodes will be deployed."
}

variable "cluster_version" {
  type        = string
  description = "Version of the Kubernetes cluster."
}

variable "authentication_mode" {
  type        = string
  default     = "API_AND_CONFIG_MAP"
  description = "Authentication mode for the EKS cluster."
}

variable "capacity_type" {
  type        = string
  default     = "SPOT"
  description = "Capacity type for the worker nodes (e.g., 'ON_DEMAND', 'SPOT')."
}

variable "instance_types" {
  type        = list(string)
  default     = ["t3.medium"]
  description = "List of instance types to be used for the worker nodes."
}

variable "node_scaling_config" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
  description = "Configuration for node scaling, specifying desired, maximum, and minimum sizes."
}

variable "bootstrap_creator_admin_access" {
  type        = bool
  default     = true
  description = "Flag indicating whether the bootstrap user should have admin access."
}

variable "aws_region" {
  type        = string
  description = "AWS region where resources will be deployed."
}
