resource "aws_eks_addon" "vpc_cni_addon" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "kube_proxy_addon" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "eks_pod_identity_addon" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "eks-pod-identity-agent"
}

resource "aws_eks_addon" "coredns_addon" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "coredns"
  depends_on = [ aws_eks_node_group.this ]
}