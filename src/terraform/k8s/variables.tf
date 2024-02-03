variable "application_name" {
  type        = string
  description = "Provided by pipeline"
}
variable "environment_name" {
  type        = string
  description = "Provided by pipeline"
}
variable "resource_group_name" {
  type        = string
  description = "Provided by pipeline"
}
variable "kubernetes_cluster_name" {
  type        = string
  description = "Provided by pipeline"
}
variable "container_registry" {
  type        = string
  description = "Provided by pipeline"
}
variable "workload_managed_identity_id" {
  type        = string
  description = "Provided by pipeline"
}
variable "keyvault_name" {
  type        = string
  description = "Provided by pipeline"
}
variable "cosmos_endpoint" {
  type        = string
  description = "Provided by pipeline"
}
variable "user_svc_database" {
  type        = string
  description = "Provided by pipeline"
}
variable "backend_ip_address" {
  type        = string
  description = "Provided by pipeline"
}
variable "backend_nodepool" {
  type        = string
  description = "Provided by pipeline"
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