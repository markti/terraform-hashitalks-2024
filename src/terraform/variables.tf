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
variable "github_runner_network" {
  type = object({
    resource_group_name  = string
    virtual_network_name = string
  })
}