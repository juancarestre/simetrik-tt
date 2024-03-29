resource "kubernetes_manifest" "namespace_game_2048" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Namespace"
    "metadata" = {
      "name" = "game-2048"
    }
  }
}

resource "kubernetes_manifest" "deployment_game_2048_deployment_2048" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "name" = "deployment-2048"
      "namespace" = "game-2048"
    }
    "spec" = {
      "replicas" = 5
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/name" = "app-2048"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app.kubernetes.io/name" = "app-2048"
          }
        }
        "spec" = {
          "containers" = [
            {
              "image" = "public.ecr.aws/l6m2t8p7/docker-2048:latest"
              "imagePullPolicy" = "Always"
              "name" = "app-2048"
              "ports" = [
                {
                  "containerPort" = 80
                },
              ]
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service_game_2048_service_2048" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "name" = "service-2048"
      "namespace" = "game-2048"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 80
          "protocol" = "TCP"
          "targetPort" = 80
        },
      ]
      "selector" = {
        "app.kubernetes.io/name" = "app-2048"
      }
      "type" = "NodePort"
    }
  }
}

resource "kubernetes_manifest" "ingress_game_2048_ingress_2048" {
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind" = "Ingress"
    "metadata" = {
      "annotations" = {
        "alb.ingress.kubernetes.io/scheme" = "internet-facing"
        "alb.ingress.kubernetes.io/target-type" = "ip"
      }
      "name" = "ingress-2048"
      "namespace" = "game-2048"
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
                    "name" = "service-2048"
                    "port" = {
                      "number" = 80
                    }
                  }
                }
                "path" = "/"
                "pathType" = "Prefix"
              },
            ]
          }
        },
      ]
    }
  }
}
