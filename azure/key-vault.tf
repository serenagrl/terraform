data "azurerm_client_config" "current" {
  count = local.key_vault.enabled ? 1 : 0
}

resource "random_integer" "vault_random" {
  count = local.key_vault.enabled ? 1 : 0

  max = 99999
  min = 10000
}

resource "azurerm_key_vault" "aks" {
  count = local.key_vault.enabled ? 1 : 0

  name                       = "${local.project}-key-vault-${random_integer.vault_random[0].result}"

  location                   = azurerm_resource_group.aks.location
  resource_group_name        = azurerm_resource_group.aks.name
  tenant_id                  = data.azurerm_client_config.current[0].tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  enabled_for_deployment        = true
  purge_protection_enabled      = false

  access_policy {
    tenant_id = data.azurerm_client_config.current[0].tenant_id
    object_id = data.azurerm_client_config.current[0].object_id

    key_permissions = [
      "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List",
      "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey",
      "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"
    ]

    secret_permissions = [
      "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
    ]

    certificate_permissions = [
      "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers",
      "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers",
      "Purge", "Recover", "Restore", "SetIssuers", "Update"
    ]
  }

  lifecycle {
    ignore_changes = [
      access_policy
    ]
  }
}

resource "azuread_application_registration" "external_secrets" {
  count = local.key_vault.enabled ? 1 : 0

  display_name     = "${local.project}-key-vault"
  description      = "Stores secrets for ${local.project}"
  sign_in_audience = "AzureADMyOrg"
}

resource "azuread_service_principal" "external_secrets" {
  count = local.key_vault.enabled ? 1 : 0

  client_id                    = azuread_application_registration.external_secrets[0].client_id
  app_role_assignment_required = false
  owners                       = [data.azurerm_client_config.current[0].object_id]

  feature_tags {
    enterprise = true
  }
}

resource "azurerm_key_vault_access_policy" "external_secrets" {
  count = local.key_vault.enabled ? 1 : 0

  key_vault_id = azurerm_key_vault.aks[0].id
  tenant_id    = data.azurerm_client_config.current[0].tenant_id
  object_id    = azuread_service_principal.external_secrets[0].object_id

  key_permissions = [
    "Get", "List"
  ]

  secret_permissions = [
    "Get", "List"
  ]

  certificate_permissions = [
    "Get", "List"
  ]

  lifecycle {
    ignore_changes = [
      key_permissions,
      secret_permissions,
      certificate_permissions
    ]
  }
}