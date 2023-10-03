# Create front door.
resource "azurerm_frontdoor" "fd" {
  resource_group_name = var.resource_group_name
  name                = var.fd_name

  # The default url without custom domains; must match azurerm_frontdoor_fd.name.
  frontend_endpoint {
    name      = var.fd_name
    host_name = "${var.fd_name}.azurefd.net"
  }

  # Custom domain name 1.
  frontend_endpoint {
    name      = "prd-rhod3rz-com"
    host_name = "prd.rhod3rz.com"
  }

  # Custom domain name 2.
  frontend_endpoint {
    name      = "stg-rhod3rz-com"
    host_name = "stg.rhod3rz.com"
  }

  # Backend pool settings.
  backend_pool_settings {
    backend_pools_send_receive_timeout_seconds   = 60
    enforce_backend_pools_certificate_name_check = "false"
  }

  # Backend pool 1 - prd.
  backend_pool {
    name = "be-prd-rhod3rz-com"
    backend {
      host_header = "${var.be_prd_rhod3rz_com_pri}.azurewebsites.net"
      address     = "${var.be_prd_rhod3rz_com_pri}.azurewebsites.net"
      http_port   = 80
      https_port  = 443
      priority    = 1
    }
    backend {
      host_header = "${var.be_prd_rhod3rz_com_sec}.azurewebsites.net"
      address     = "${var.be_prd_rhod3rz_com_sec}.azurewebsites.net"
      http_port   = 80
      https_port  = 443
      priority    = 2
    }
    load_balancing_name = "loadbalancingsettings"
    health_probe_name   = "healthprobesettings"
  }

  # Backend pool 2 - stg.
  backend_pool {
    name = "be-stg-rhod3rz-com"
    backend {
      host_header = "${var.be_stg_rhod3rz_com_pri}.azurewebsites.net"
      address     = "${var.be_stg_rhod3rz_com_pri}.azurewebsites.net"
      http_port   = 80
      https_port  = 443
      priority    = 1
    }
    backend {
      host_header = "${var.be_stg_rhod3rz_com_sec}.azurewebsites.net"
      address     = "${var.be_stg_rhod3rz_com_sec}.azurewebsites.net"
      http_port   = 80
      https_port  = 443
      priority    = 2
    }
    load_balancing_name = "loadbalancingsettings"
    health_probe_name   = "healthprobesettings"
  }

  # Routing rule 1 - prd.
  routing_rule {
    name               = "rr-prd-rhod3rz-com"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["prd-rhod3rz-com"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "be-prd-rhod3rz-com"
    }
  }

  # Routing rule 2 - stg.
  routing_rule {
    name               = "rr-stg-rhod3rz-com"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["stg-rhod3rz-com"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "be-stg-rhod3rz-com"
    }
  }

  backend_pool_load_balancing {
    name = "loadbalancingsettings"
  }

  backend_pool_health_probe {
    name = "healthprobesettings"
  }
}

# Custom https setting 1 - prd.
resource "azurerm_frontdoor_custom_https_configuration" "fchc_1" {
  depends_on                        = [azurerm_frontdoor.fd]
  frontend_endpoint_id              = azurerm_frontdoor.fd.frontend_endpoints["prd-rhod3rz-com"]
  custom_https_provisioning_enabled = true
  custom_https_configuration {
    certificate_source = "FrontDoor"
  }
}

# Custom https setting 2 - stg.
resource "azurerm_frontdoor_custom_https_configuration" "fchc_2" {
  depends_on                        = [azurerm_frontdoor.fd]
  frontend_endpoint_id              = azurerm_frontdoor.fd.frontend_endpoints["stg-rhod3rz-com"]
  custom_https_provisioning_enabled = true
  custom_https_configuration {
    certificate_source = "FrontDoor"
  }
}
