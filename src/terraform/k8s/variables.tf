variable "application_name" {
  type = string
}
variable "environment_name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "kubernetes_cluster_name" {
  type = string
}
variable "workload_managed_identity_id" {
  type = string
}
variable "keyvault_name" {
  type = string
}
variable "container_registry" {
  type = string
}
variable "k8s_namespace" {
  type = string
}
variable "k8s_service_account_name" {
  type = string
}
variable "health_check_image" {
  type = object({
    name    = string
    version = string
  })
}
variable "user_svc_image" {
  type = object({
    name    = string
    version = string
  })
}