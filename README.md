# terraform-cloudflare-tailscale-blocklist

Terraform module for deploying a Cloudflare blocklist on Tailscale exit nodes.

## Inspiration

https://blog.marcolancini.it/2022/blog-serverless-ad-blocking-with-cloudflare-gateway/
https://community.cloudflare.com/t/adding-multiple-lists-to-cloudflare-zerotrust-dns-policy/497393/3
https://icloudgo.net/posts/block-ads-with-cloudflare-zero-trust/

> [!WARNING]\
> Cloudflare Zero Trust (CZT) expects a default location to exist at all times. First, manually create an empty CZT default location before working with this module.

## Usage

### Single IP

```hcl
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

module "blocklist" {
  source                = "github.com/bendwyer/terraform-cloudflare-tailscale-blocklist"

  cloudflare_account_id = "abcdefgh123456"
  public_ip_address     = "123.456.789"
}
```

### Multiple IPs

```hcl
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
```

### Tailscale exit nodes

```hcl
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
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | >=4.25.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >=3.4.1 |
| <a name="requirement_tailscale"></a> [tailscale](#requirement\_tailscale) | >=0.13.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | >=4.25.0 |
| <a name="provider_http"></a> [http](#provider\_http) | >=3.4.1 |
| <a name="provider_tailscale"></a> [tailscale](#provider\_tailscale) | >=0.13.13 |



## Resources

| Name | Type |
|------|------|
| [cloudflare_teams_list.blocklist](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/teams_list) | resource |
| [cloudflare_teams_location.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/teams_location) | resource |
| [cloudflare_teams_rule.blocklist_policy](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/teams_rule) | resource |
| [cloudflare_teams_rule.security_policy](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/teams_rule) | resource |
| [tailscale_dns_nameservers.this](https://registry.terraform.io/providers/tailscale/tailscale/latest/docs/resources/dns_nameservers) | resource |
| [http_http.blocklist_url](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudflare_account_id"></a> [cloudflare\_account\_id](#input\_cloudflare\_account\_id) | Cloudflare account ID. | `string` | n/a | yes |
| <a name="input_public_ip_address"></a> [public\_ip\_address](#input\_public\_ip\_address) | A set of public IP address(es) where Cloudflare Gateway will be enabled. | `set(string)` | n/a | yes |
| <a name="input_cloudflare_dns_resolvers_ipv4"></a> [cloudflare\_dns\_resolvers\_ipv4](#input\_cloudflare\_dns\_resolvers\_ipv4) | For queries over IPv4, the default DNS resolver IP addresses are anycast IP addresses, and they are shared across every Cloudflare Zero Trust account. See https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/agentless/dns/locations/dns-resolver-ips/#ipv4-address for more information. | `list(string)` | <pre>[<br>  "172.64.36.1",<br>  "172.64.36.2"<br>]</pre> | no |



