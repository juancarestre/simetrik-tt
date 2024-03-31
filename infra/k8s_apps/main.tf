resource "kubernetes_manifest" "deployment" {
  depends_on = [null_resource.build_push_dkr_img]
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "Deployment"
    "metadata" = {
      "name"      = "${var.app_name}"
      "namespace" = "default"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/name" = "${var.app_name}"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app.kubernetes.io/name" = "${var.app_name}"
          }
        }
        "spec" = {
          "containers" = [
            {
              "image"           = "${aws_ecr_repository.ecr_repo.repository_url}:${var.image_version}"
              "imagePullPolicy" = "Always"
              "name"            = "${var.app_name}"
              "command"         = var.command
              "ports" = [
                {
                  "containerPort" = "${var.container_port}"
                },
              ]
              "env" = [
                {
                  "name"  = "${var.envs[0].name}"
                  "value" = "${var.envs[0].value}"
                }
              ]
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service" {
  depends_on = [null_resource.build_push_dkr_img]
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Service"
    "metadata" = {
      "name"      = "${var.app_name}"
      "namespace" = "default"
    }
    "spec" = {
      "ports" = [
        {
          "port"       = "${var.container_port}"
          "protocol"   = "TCP"
          "targetPort" = "${var.container_port}"
        },
      ]
      "selector" = {
        "app.kubernetes.io/name" = "${var.app_name}"
      }
      "type" = "NodePort"
    }
  }
}

resource "kubernetes_manifest" "ingress" {
  count      = var.create_ingress ? 1 : 0
  depends_on = [null_resource.build_push_dkr_img]

  wait {
    fields ={
       "status.loadBalancer.ingress[0].hostname" = "*"
    }
  }
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind"       = "Ingress"
    "metadata" = {
      "annotations" = {
        "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
        "alb.ingress.kubernetes.io/target-type" = "ip"
      }
      "name"      = "${var.app_name}"
      "namespace" = "default"
    }
    "spec" = {
      "ingressClassName" = "alb"
      "rules" = [
        {
          "http" = {
            "paths" = [
              {
                "backend" = {
                  "service" = {
                    "name" = "${var.app_name}"
                    "port" = {
                      "number" = "${var.container_port}"
                    }
                  }
                }
                "path"     = "/"
                "pathType" = "Prefix"
              },
            ]
          }
        },
      ]
    }
  }
}
