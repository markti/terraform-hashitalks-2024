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
  value = azurerm_user_assigned_identity.workload.client_id
}
output "keyvault_name" {
  value = azurerm_key_vault.main.name
}
output "backend_ip_address" {
  value = local.backend_ip_address
}
output "backend_nodepool" {
  value = azurerm_kubernetes_cluster_node_pool.workload.name
}