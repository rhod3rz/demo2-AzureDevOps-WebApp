# Create dns records.
module "az_dns" {
  count   = var.environment == "prd" ? 1 : 0 # Conditionally create the resource.
  source  = "./modules/az_dns"               # The path to the module.
  fd_name = "fd-${var.unique_id}"            # The front door name.
}
