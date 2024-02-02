output "registry_endpoint" {
  value = azurerm_container_registry.main.login_server
}
output "aks_host" {
  value     = try(azurerm_kubernetes_cluster.main.kube_admin_config[0].host, "")
  sensitive = true
}