resource "azurerm_application_insights" "app_insights" {
  count = local.telemetry.enabled ? 1 : 0

  name                = "${local.project}-app-insights"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  application_type    = "web"
  retention_in_days   = local.telemetry.app_insights_retention_days
  workspace_id        = azurerm_log_analytics_workspace.log_analytics_workspace[0].id
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  count = local.telemetry.enabled ? 1 : 0

  name                = "log-analytics-workspace"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_action_group" "action_group" {
  count = local.telemetry.enabled ? 1 : 0

  name                = "${local.project}-action-group"
  resource_group_name = azurerm_resource_group.aks.name
  short_name          = "${local.project}"
}

resource "azurerm_monitor_smart_detector_alert_rule" "failure_anomalies" {
  count = local.telemetry.enabled ? 1 : 0

  name                = "Failure Anomalies - ${azurerm_application_insights.app_insights[0].name}"
  resource_group_name = azurerm_resource_group.aks.name
  detector_type       = "FailureAnomaliesDetector"
  scope_resource_ids  = [azurerm_application_insights.app_insights[0].id]
  severity            = "Sev0"
  frequency           = "PT1M"
  action_group {
    ids = [azurerm_monitor_action_group.action_group[0].id]
  }
}