resource "kubernetes_namespace" "app" {
  metadata {

    labels = {
      name = var.k8s_namespace
    }

    name = var.k8s_namespace
  }
}