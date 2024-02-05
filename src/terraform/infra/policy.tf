data "azurerm_policy_set_definition" "az_resiliency" {
  name = "130fb88f-0fc9-4678-bfe1-31022d71c7d5"
}

resource "azurerm_resource_group_policy_assignment" "az_resiliency" {
  name                 = "pol-az-resiliency"
  resource_group_id    = azurerm_resource_group.main.id
  policy_definition_id = data.azurerm_policy_definition.az_resiliency.id

  parameters = <<PARAMS
    {
      "effect": {
        "value": "Audit"
      },
      "allow": {
        "value": "Both"
      }
    }
PARAMS
}
