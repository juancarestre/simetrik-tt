resource "aws_ecr_repository" "ecr_repo" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

locals {
  dkr_img_src_sha256 = sha256(join("", [for f in fileset(".", "../apps/nea-translator/**") : file(f)]))
  docker_build_and_push = <<-EOT
        cd ../apps/nea-translator/
        docker build -t ${aws_ecr_repository.ecr_repo.repository_url}:${image_version} --platform=linux/amd64 .

        aws --profile ${var.aws_profile} ecr get-login-password --region ${var.aws_region} | \
            docker login --username AWS --password-stdin ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com

        docker push ${aws_ecr_repository.ecr_repo.repository_url}:${image_version}
    EOT
}

resource "null_resource" "build_push_dkr_img" {
  triggers = {
    detect_docker_source_changes = var.force_image_rebuild == true ? timestamp() : local.dkr_img_src_sha256
  }
  provisioner "local-exec" {
    command = local.docker_build_and_push
  }
}
