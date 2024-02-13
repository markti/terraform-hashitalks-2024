resource "azurerm_public_ip" "aks_outbound_ip" {
  name                = "pip-aks-${var.application_name}-${var.environment_name}-${random_string.main.result}-outbound"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"
  zones               = [1, 2, 3]
  allocation_method   = "Static"
  ip_version          = "IPv4"
}

module "aks_outbound_pip_monitor_diagnostic" {
  source  = "markti/azure-terraformer/azurerm//modules/monitor/diagnostic-setting/rando"
  version = "1.0.10"

  resource_id                = azurerm_public_ip.aks_outbound_ip.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  logs = [
    "DDoSProtectionNotifications",
    "DDoSMitigationFlowLogs",
    "DDoSMitigationReports"
  ]

}

resource "azurerm_user_assigned_identity" "aks_cluster" {
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  name                = "mi-aks-${var.application_name}-${var.environment_name}-${random_string.main.result}"
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                = azurerm_virtual_network.main.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_cluster.principal_id
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}


resource "azurerm_kubernetes_cluster" "main" {

  name                = "aks-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku_tier                          = "Standard"
  kubernetes_version                = "1.27.7"
  dns_prefix                        = "${var.application_name}-${var.environment_name}"
  node_resource_group               = "rg-${var.application_name}-${var.environment_name}-${random_string.main.result}-nodes"
  role_based_access_control_enabled = true  # allows Entra ID identities to be used inside k8s
  oidc_issuer_enabled               = true  # enables Entra ID SSO
  workload_identity_enabled         = true  # allows k8s resources to impersonate Entra ID identities
  local_account_disabled            = false # allows GitHub Actions to use simple authN to manage k8s resources
  automatic_channel_upgrade         = "patch"
  node_os_channel_upgrade           = "NodeImage"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_cluster.id]
  }

  # allows Entra ID groups to be cluster administrators
  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = var.admin_groups
    azure_rbac_enabled     = true
  }

  # resource and security isolation for k8s system processes
  default_node_pool {
    name                = "npsystem"
    node_count          = var.aks_configuration.system_pool.capacity
    vm_size             = var.aks_configuration.system_pool.sku
    enable_auto_scaling = false
    os_sku              = "Mariner"
    vnet_subnet_id      = azurerm_subnet.workload.id
    type                = "VirtualMachineScaleSets"
    zones               = [1, 2, 3]
  }

  network_profile {

    # Azure CNI overlay
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "10.32.0.0/16"
    dns_service_ip    = "10.32.0.10"

    # allows for more control over egress traffic in the future
    load_balancer_profile {
      outbound_ip_address_ids = [azurerm_public_ip.aks_outbound_ip.id]
    }

  }

  # maintenance windows
  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Friday"
    utc_offset  = "-05:00"
    start_time  = "20:00"
  }

  maintenance_window_node_os {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Saturday"
    utc_offset  = "-05:00"
    start_time  = "20:00"
  }

  # adds KeyVault Secrets Provider
  key_vault_secrets_provider {
    secret_rotation_enabled  = false
    secret_rotation_interval = "2m"
  }

  # observability
  microsoft_defender {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }
}

module "aks_monitor_diagnostic" {
  source  = "markti/azure-terraformer/azurerm//modules/monitor/diagnostic-setting/rando"
  version = "1.0.10"

  resource_id                = azurerm_kubernetes_cluster.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  logs = [
    "kube-apiserver",
    "kube-audit",
    "kube-audit-admin",
    "kube-controller-manager",
    "kube-scheduler",
    "cluster-autoscaler",
    "cloud-controller-manager",
    "guard",
    "csi-azuredisk-controller",
    "csi-azurefile-controller",
    "csi-snapshot-controller"
  ]

}

resource "azurerm_kubernetes_cluster_node_pool" "workload" {

  name                  = "npworkload"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.aks_configuration.workload_pool.sku
  enable_auto_scaling   = true
  os_sku                = "Mariner"
  vnet_subnet_id        = azurerm_subnet.workload.id
  zones                 = [1, 2, 3]
  node_count            = var.aks_configuration.workload_pool.capacity.ready
  min_count             = var.aks_configuration.workload_pool.capacity.min
  max_count             = var.aks_configuration.workload_pool.capacity.max

}

/*
resource "azurerm_kubernetes_cluster_node_pool" "zone1" {

  name                  = "npzone1"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.aks_configuration.workload_pool.sku
  enable_auto_scaling   = true
  os_sku                = "Mariner"
  vnet_subnet_id        = azurerm_subnet.workload.id
  zones                 = [1]
  node_count            = var.aks_configuration.workload_pool.capacity.ready
  min_count             = var.aks_configuration.workload_pool.capacity.min
  max_count             = var.aks_configuration.workload_pool.capacity.max

}

resource "azurerm_kubernetes_cluster_node_pool" "zone2" {

  name                  = "npzone1"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.aks_configuration.workload_pool.sku
  enable_auto_scaling   = true
  os_sku                = "Mariner"
  vnet_subnet_id        = azurerm_subnet.workload.id
  zones                 = [2]
  node_count            = var.aks_configuration.workload_pool.capacity.ready
  min_count             = var.aks_configuration.workload_pool.capacity.min
  max_count             = var.aks_configuration.workload_pool.capacity.max

}

resource "azurerm_kubernetes_cluster_node_pool" "zone3" {

  name                  = "npzone1"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.aks_configuration.workload_pool.sku
  enable_auto_scaling   = true
  os_sku                = "Mariner"
  vnet_subnet_id        = azurerm_subnet.workload.id
  zones                 = [3]
  node_count            = var.aks_configuration.workload_pool.capacity.ready
  min_count             = var.aks_configuration.workload_pool.capacity.min
  max_count             = var.aks_configuration.workload_pool.capacity.max

}
*/