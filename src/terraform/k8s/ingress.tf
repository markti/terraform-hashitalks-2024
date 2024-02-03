resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.9.0"
  namespace  = "ingress-controller"

  set {
    name  = "controller.replicaCount"
    value = 3
  }

  set {
    name  = "controller.nodeSelector.kubernetes\\.io/os"
    value = "linux"
  }

  set {
    name  = "controller.nodeSelector.agentpool"
    value = "npworkload"
  }

  set {
    name  = "controller.image.registry"
    value = var.container_registry
  }

  set {
    name  = "controller.image.image"
    value = "oss/kubernetes/ingress/nginx-ingress-controller"
  }

  set {
    name  = "controller.image.tag"
    value = "v1.9.5"
  }

  set {
    name  = "controller.image.digest"
    value = ""
  }

  set {
    name  = "controller.admissionWebhooks.patch.nodeSelector.kubernetes\\.io/os"
    value = "linux"
  }

  set {
    name  = "controller.admissionWebhooks.patch.nodeSelector.agentpool"
    value = "npworkload"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
    value = "true"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-ipv4"
    value = "10.0.3.250"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
    value = "/healthz"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "controller.admissionWebhooks.patch.image.registry"
    value = var.container_registry
  }

  set {
    name  = "controller.admissionWebhooks.patch.image.image"
    value = "oss/kubernetes/ingress/kube-webhook-certgen"
  }

  set {
    name  = "controller.admissionWebhooks.patch.image.tag"
    value = "v1.9.5"
  }

  set {
    name  = "controller.admissionWebhooks.patch.image.digest"
    value = ""
  }
}
