variable "application_name" {
  type = string
}
variable "environment_name" {
  type = string
}
variable "primary_region" {
  type = string
}
variable "address_space" {
  type = string
}
variable "vpn_address_space" {
  type = string
}
variable "vpn_application_id" {
  type = string
}
variable "admin_groups" {
  type = list(string)
}
variable "aks_configuration" {
  type = object({
    system_pool = object({
      sku      = string
      capacity = number
    })
    workload_pool = object({
      sku = string
      capacity = object({
        ready = number
        min   = number
        max   = number
      })
    })
  })
}
variable "app_gateway_configuration" {
  type = object({
    sku = string
    capacity = object({
      ready = number
      min   = number
      max   = number
    })
  })
}
variable "github_runner_network" {
  type = object({
    resource_group_name  = string
    virtual_network_name = string
  })
}
variable "k8s_namespace" {
  type = string
}
variable "k8s_service_account_name" {
  type = string
}