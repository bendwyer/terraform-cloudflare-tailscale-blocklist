terraform {
  required_version = ">= 1.1.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">=4.25.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">=3.4.1"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = ">=0.13.13"
    }
  }
}
