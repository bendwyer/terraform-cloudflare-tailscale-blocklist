terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
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
    time = {
      source  = "hashicorp/time"
      version = "~> 0.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

provider "aws" {
  alias  = "jp"
  region = "ap-northeast-1"
}

provider "aws" {
  alias  = "us"
  region = "us-east-1"
}

provider "cloudflare" {}

provider "tailscale" {}

locals {
  public_ip_address = [
    module.de_exit_node.public_ip_address,
    module.jp_exit_node.public_ip_address,
    module.us_exit_node.public_ip_address
  ]
}

resource "tailscale_acl" "this" {
  acl = templatefile("${path.root}/acl.json.tftpl", {
    tailscale_exit_node_tag_name = "exit"
  })
}

module "de_exit_node" {
  source = "github.com/bendwyer/terraform-aws-lightsail-tailscale-exit-node"
}

module "jp_exit_node" {
  source = "github.com/bendwyer/terraform-aws-lightsail-tailscale-exit-node"

  providers = {
    aws = aws.jp
  }
  lightsail_region = "ap-northeast-1"
}

module "us_exit_node" {
  source = "github.com/bendwyer/terraform-aws-lightsail-tailscale-exit-node"

  providers = {
    aws = aws.us
  }
  lightsail_region = "us-east-1"
}

module "blocklist" {
  source                = "github.com/bendwyer/terraform-cloudflare-tailscale-blocklist"

  cloudflare_account_id = "abcdefgh123456"
  public_ip_address     = local.public_ip_address
}
