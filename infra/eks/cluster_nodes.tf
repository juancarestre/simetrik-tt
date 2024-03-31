resource "aws_eks_node_group" "this" {
  cluster_name           = aws_eks_cluster.this.name
  node_group_name_prefix = var.eks_cluster_name
  node_role_arn          = aws_iam_role.node_group_role.arn
  subnet_ids             = var.private_subnet_ids

  scaling_config {
    desired_size = var.node_scaling_config.desired_size
    max_size     = var.node_scaling_config.max_size
    min_size     = var.node_scaling_config.min_size
  }

  capacity_type  = var.capacity_type
  instance_types = var.instance_types

  # remote_access { #TODO: temporal
  #   ec2_ssh_key = "studying-linux"
  # }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}