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
    depends_on = [ module.network ]
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
  depends_on = [ module.eks ]
  provisioner "local-exec" {
    command     = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name} --profile ${var.aws_profile}"
    interpreter = ["bash", "-c"]
  }
}

module "load_balancer_controller" {
    source = "./loadbalancercontroller"
    aws_region = var.aws_region
    cluster_name = module.eks.cluster_name
    environment = var.environment
    vpc_id = module.network.vpc_id
    oidc_provider_arn = module.eks.cluster_openid_oidc_provider_arn
}

module "k8s_app_client" {
    source = "./k8s_apps"
    depends_on = [ module.load_balancer_controller, module.eks, module.network ]
    aws_profile = var.aws_profile
    aws_account_id = var.aws_account_id
    aws_region = var.aws_region
    app_name = "nea-translator"
    container_port = 8000
    force_image_rebuild = false
    command = ["pipenv", "run", "start_container"]
    image_version = "latest"
    app_path = "../apps/nea-translator/"
    create_ingress = true
    envs = [{
        name: "GRPC_SERVER"
        value: "nea-translator-grpc-server:50051"
    }]
}

module "k8s_app_grpc_server" {
    source = "./k8s_apps"
    depends_on = [ module.load_balancer_controller, module.eks, module.network ]
    aws_profile = var.aws_profile
    aws_account_id = var.aws_account_id
    aws_region = var.aws_region
    app_name = "nea-translator-grpc-server"
    container_port = 50051
    force_image_rebuild = false
    command = ["pipenv", "run", "start_container"]
    image_version = "latest"
    app_path = "../apps/nea-translator-grpc-server/"
    create_ingress = false
    envs = [ {
      name = "OPENAI_API_KEY"
      value = var.OPENAI_API_KEY
    } ]
}

module "codebuild_project" {
  source = "./codebuild"
  account_id = var.aws_account_id
  aws_region = var.aws_region
  project_env = var.environment
  project_name = var.project_name
  repository_url = var.repository_url
  AWS_ACCESS_KEY_ID = var.AWS_ACCESS_KEY_ID
  AWS_ACCESS_KEY_SECRET = var.AWS_ACCESS_KEY_SECRET
  aws_profile = var.aws_profile
}