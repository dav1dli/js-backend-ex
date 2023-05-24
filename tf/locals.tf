locals {
  resource_group               = "RG-${var.region}-${var.environment}-${var.project}"
  vnet_name                    = "VNET-${var.region}-${var.environment}-${var.project}"
  bstn_subnet                  = "SBNT-BSTN-${var.region}-${var.environment}-${var.project}"
  mng_subnet                   = "SBNT-MNG-${var.region}-${var.environment}-${var.project}"
  priv_endpt_subnet            = "SBNT-PEP-${var.region}-${var.environment}-${var.project}"
  acr_name                     = "ACR${var.environment}${var.project}"
  acr_pep_name                 = "PEP-ACR-${var.region}-${var.environment}-${var.project}"
  kv_name                      = "KV-${var.region}-${var.environment}-${var.project}"
  kv_pep_name                  = "PEP-KV-${var.region}-${var.environment}-${var.project}"
  log_analytics_workspace_name = "LAW-${var.region}-${var.environment}-${var.project}"
}