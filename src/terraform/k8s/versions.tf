terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25.0"
    }
  }
  backend "azurerm" {
  }
}

data "azurerm_kubernetes_cluster" "main" {
  name                = "aks-aztflab-dev-agyhy3jv"
  resource_group_name = "rg-aztflab-dev-agyhy3jv"
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.main.kube_admin_config[0].host
  client_key             = base64decode(data.azurerm_kubernetes_cluster.main.kube_admin_config[0].client_key)
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.main.kube_admin_config[0].client_certificate)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.main.kube_admin_config[0].cluster_ca_certificate)
}