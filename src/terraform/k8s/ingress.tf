resource "kubernetes_namespace" "ingress_nginx" {
  metadata {

    labels = {
      name = "ingress-controller"
    }

    name = "ingress-controller"
  }
}

locals {
  controller_image = {
    registry = "mcr.microsoft.com"
    name     = "oss/kubernetes/ingress/nginx-ingress-controller"
    version  = "v1.9.5"
  }
  patch_image = {
    registry = "mcr.microsoft.com"
    name     = "oss/kubernetes/ingress/kube-webhook-certgen"
    version  = "v1.9.5"
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.9.0"
  namespace  = kubernetes_namespace.ingress_nginx.metadata.0.name
  timeout    = 600

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
    value = var.backend_nodepool
  }

  set {
    name  = "controller.image.registry"
    value = local.controller_image.registry
  }

  set {
    name  = "controller.image.image"
    value = local.controller_image.name
  }

  set {
    name  = "controller.image.tag"
    value = local.controller_image.version
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
    value = var.backend_nodepool
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
    value = "true"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-ipv4"
    value = var.backend_ip_address
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
    value = local.patch_image.registry
  }

  set {
    name  = "controller.admissionWebhooks.patch.image.image"
    value = local.patch_image.name
  }

  set {
    name  = "controller.admissionWebhooks.patch.image.tag"
    value = local.patch_image.version
  }

  set {
    name  = "controller.admissionWebhooks.patch.image.digest"
    value = ""
  }
}
