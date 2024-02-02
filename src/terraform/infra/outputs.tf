output "resource_group_name" {
  value = azurerm_resource_group.main.name
}
output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}
output "container_registry" {
  value = azurerm_container_registry.main.login_server
}
output "workload_managed_identity_id" {
  value = azurerm_user_assigned_identity.workload.principal_id
}
output "keyvault_name" {
  value = azurerm_key_vault.main.name
}