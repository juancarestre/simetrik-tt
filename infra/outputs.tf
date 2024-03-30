data "kubernetes_resource" "loadbalancerurl" {
    depends_on = [ module.k8s_app_client ]
  api_version    = "networking.k8s.io/v1"
  kind           = "Ingress"
  metadata {
    name = "nea-translator"
    namespace = "default"
  }
}

output "alb_endpoint" {
  value = data.kubernetes_resource.loadbalancerurl.object.status.loadBalancer.ingress
}