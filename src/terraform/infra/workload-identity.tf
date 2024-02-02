
resource "azurerm_user_assigned_identity" "workload" {
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  name                = "mi-workload-${var.application_name}-${var.environment_name}-${random_string.main.result}"
}
resource "azurerm_federated_identity_credential" "workload" {
  name                = azurerm_user_assigned_identity.workload.name
  resource_group_name = azurerm_resource_group.main.name
  audience            = []
  issuer              = azurerm_kubernetes_cluster.main.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.workload.id
  subject             = "system:serviceaccount:${var.k8s_namespace}:${k8s_service_account_name}"
}