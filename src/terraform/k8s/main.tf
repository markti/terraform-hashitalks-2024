resource "kubernetes_namespace" "app" {
  metadata {

    labels = {
      name = "app"
    }

    name = "app"
  }
}