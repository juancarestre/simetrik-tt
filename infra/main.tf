module "network" {
    source = "./networking"
    aws_region = var.aws_region
    cidr_block = var.cidr_block
    project_name = var.project_name
    environment = var.environment
    count_private_subnet = 2
    count_public_subnet = 2
    eks_cluster_name = "${var.project_name}-${var.environment}-cluster"
}

module "eks" {
    source = "./eks"
    eks_cluster_name = "${var.project_name}-${var.environment}-cluster"
    private_subnet_ids = module.network.private_subnet_ids
    cluster_version = "1.28"
    aws_region = var.aws_region
    node_scaling_config = {
        desired_size = 1
        max_size = 2
        min_size = 1
    }
}

resource "null_resource" "get_kube_config" {
  provisioner "local-exec" {
    command     = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name} --profile ${var.aws_profile}"
    interpreter = ["bash", "-c"]
  }
}

# https://docs.aws.amazon.com/eks/latest/userguide/lbc-manifest.htmlå
module "load_balancer_controller" {
    source = "./loadbalancercontroller"
    aws_region = var.aws_region
    cluster_name = module.eks.cluster_name
    environment = var.environment
    vpc_id = module.network.vpc_id
    oidc_provider_arn = module.eks.cluster_openid_oidc_provider_arn
}

module "k8s_apps" {
    source = "./k8s_apps"
    depends_on = [ module.load_balancer_controller ]
    aws_profile = var.aws_profile
    aws_account_id = var.aws_account_id
    aws_region = var.aws_region
    app_name = "nea-translator"
    container_port = 8000
    force_image_rebuild = true
    command = "pipenv run start_container"
    image_version = "2"
}