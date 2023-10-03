# Create linux app service plan.
resource "azurerm_service_plan" "sp" {
  location            = var.location
  resource_group_name = var.resource_group_name
  name                = var.plan_name
  os_type             = "Linux"
  sku_name            = "P1v2"
}

# Create app service.
resource "azurerm_linux_web_app" "lwa" {
  location            = var.location
  resource_group_name = var.resource_group_name
  name                = var.webapp_name
  service_plan_id     = azurerm_service_plan.sp.id

  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.ai_connection_string
    DOCKER_REGISTRY_SERVER_URL            = var.acr_login_server
    DOCKER_REGISTRY_SERVER_USERNAME       = var.acr_admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD       = "${data.azurerm_key_vault_secret.kv_acrdlnteudemoapps210713.value}"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = false
  }

  connection_string {
    name  = "MyDbConnection"
    type  = "SQLAzure"
    value = var.connection_string
  }

  identity {
    type = "SystemAssigned"
  }

  # Redirects http requests to https.
  https_only = true

  # Enable logs. Download logs from https://<app-name>.scm.azurewebsites.net/api/logs/docker/zip.
  logs {
    http_logs {
      file_system {
        retention_in_days = "5"
        retention_in_mb   = "25"
      }
    }
  }

  site_config {
    always_on = "true"
    application_stack {
      docker_image     = "mcr.microsoft.com/appsvc/staticsite"
      docker_image_tag = "latest"
    }
  }

  # Ignore docker image changes as ADO pipeline will manage that.
  lifecycle {
    ignore_changes = [
      site_config,
      app_settings
    ]
  }
}

# Configure web app diagnostic settings to send logs to log analytics.
resource "azurerm_monitor_diagnostic_setting" "mds" {
  name                       = "Log-Analytics"
  target_resource_id         = azurerm_linux_web_app.lwa.id
  log_analytics_workspace_id = var.law_id
  log { category = "AppServiceHTTPLogs" }
  log { category = "AppServiceConsoleLogs" }
  log { category = "AppServiceAppLogs" }
  log { category = "AppServicePlatformLogs" }
  metric { category = "AllMetrics" }
  lifecycle {
    ignore_changes = [
      log,
      metric
    ]
  }
}

# Configure web app scale out settings.
resource "azurerm_monitor_autoscale_setting" "mas" {
  depends_on          = [azurerm_service_plan.sp]
  location            = var.location
  resource_group_name = var.resource_group_name
  name                = var.autoscale_name
  target_resource_id  = azurerm_service_plan.sp.id
  profile {
    name = "default"
    capacity {
      default = 1
      minimum = 1
      maximum = 10
    }
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.sp.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 90
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.sp.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 10
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
  lifecycle {
    ignore_changes = all
  }
}

# Create app service slot.
# NOTE: Using 'azurerm_app_service_slot' instead of 'azurerm_linux_web_app_slot' due to error 'ID was missing the 'sites' element'.
resource "azurerm_app_service_slot" "ass" {
  location            = var.location
  resource_group_name = var.resource_group_name
  name                = "stg"
  app_service_name    = azurerm_linux_web_app.lwa.name
  app_service_plan_id = azurerm_service_plan.sp.id

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL          = var.acr_login_server
    DOCKER_REGISTRY_SERVER_USERNAME     = var.acr_admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = "${data.azurerm_key_vault_secret.kv_acrdlnteudemoapps210713.value}"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
  }

  site_config {
    always_on        = "true"
    linux_fx_version = "DOCKER|mcr.microsoft.com/appsvc/staticsite:latest"
  }

  identity {
    type = "SystemAssigned"
  }

  connection_string {
    name  = "MyDbConnection"
    type  = "SQLAzure"
    value = var.connection_string
  }

  # Ignore docker image changes as ADO pipeline will manage that.
  lifecycle {
    ignore_changes = [
      site_config,
      app_settings
    ]
  }
}
