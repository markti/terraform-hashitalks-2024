resource "kubernetes_manifest" "shared_secrets" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "shared-secrets"
      namespace = var.k8s_namespace
    }
    spec = {
      provider = "azure"
      secretObjects = [
        {
          data = [
            {
              key        = "app-insights-connection-string"
              objectName = "app-insights-connection-string"
            }
          ]
          secretName = "shared"
          type       = "Opaque"
        }
      ]
      parameters = {
        usePodIdentity = "false"
        clientID       = var.workload_managed_identity_id
        keyvaultName   = var.keyvault_name
        cloudName      = ""
        objects        = <<OBJECTS
      array:
        - |
          objectName: app-insights-connection-string
          objectType: secret
          objectVersion: ""
OBJECTS
        tenantId       = data.azurerm_client_config.current.tenant_id
      }
    }
  }
}