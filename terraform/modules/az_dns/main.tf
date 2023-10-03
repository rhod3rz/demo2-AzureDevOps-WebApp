######################
# CREATE DNS RECORDS #
######################
# ---------------------------------------------------------------- #
# ---------------------------------------------------------------- #
# Create cname record - prd
resource "azurerm_dns_cname_record" "dcr_prd" {
  name                = "prd"
  zone_name           = data.azurerm_dns_zone.dz.name
  resource_group_name = data.azurerm_dns_zone.dz.resource_group_name
  ttl                 = 300
  record              = "${var.fd_name}.azurefd.net"
}
# ---------------------------------------------------------------- #
# ---------------------------------------------------------------- #
# Create cname record - stg
resource "azurerm_dns_cname_record" "dcr_stg" {
  name                = "stg"
  zone_name           = data.azurerm_dns_zone.dz.name
  resource_group_name = data.azurerm_dns_zone.dz.resource_group_name
  ttl                 = 300
  record              = "${var.fd_name}.azurefd.net"
}
# ---------------------------------------------------------------- #
# ---------------------------------------------------------------- #
