output "registry_endpoint" {
  value = azurerm_container_registry.main.login_server
}
output "aks_host" {
  value = azurerm_kubernetes_cluster.diem.kube_admin_config[0].host
}