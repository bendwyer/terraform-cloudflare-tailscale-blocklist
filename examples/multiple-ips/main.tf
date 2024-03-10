terraform {
  required_version = "~> 1.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.0"
    }
  }
}

provider "cloudflare" {}

provider "tailscale" {}

locals {
  public_ip_address = [
    "123.456.789",
    "12.345.67"
  ]
}

module "blocklist" {
  source                = "github.com/bendwyer/terraform-cloudflare-tailscale-blocklist"

  cloudflare_account_id = "abcdefgh123456"
  public_ip_address     = local.public_ip_address
}
