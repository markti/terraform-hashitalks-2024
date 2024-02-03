primary_region     = "westus3"
address_space      = "10.0.0.0/22"
vpn_address_space  = "172.16.201.0/24"
vpn_application_id = "2d4e6e16-f5df-45bf-91b0-c702247ce115"
admin_groups       = ["3a8bf720-3ae5-45a3-8122-0eea50497c73"]
node_size          = "Standard_D4s_v3"
app_gateway_configuration = {
  sku = "Standard_v2"
  capacity = {
    ready = 2
    min = 3
    max = 125
  }
}
k8s_namespace            = "app"
k8s_service_account_name = "workload"

github_runner_network = {
  resource_group_name  = "rg-aztflab-dev-zgdkwdkd"
  virtual_network_name = "vnet-aztflab-dev-zgdkwdkd"
}