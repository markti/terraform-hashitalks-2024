resource "kubernetes_service_account" "workload" {
  metadata {
    name = var.k8s_service_account_name
    namespace = var.k8s_namespace
    annotations = {
        "azure.workload.identity/client-id" = var.workload_managed_identity_id
    }
  }
}