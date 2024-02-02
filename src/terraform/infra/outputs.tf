output "registry_endpoint" {
  value = azurerm_container_registry.main.login_server
}
output "aks_host" {
  value     = try(azurerm_kubernetes_cluster.main.kube_admin_config[0].host, "")
  sensitive = true
}
output "resource_group_name" {
  value = azurerm_resource_group.main.name
}
output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}
output "workload_managed_identity_id" {
  value = azurerm_user_assigned_identity.workload.principal_id
}
output "keyvault_name" {
  value = azurerm_key_vault.main.name
}