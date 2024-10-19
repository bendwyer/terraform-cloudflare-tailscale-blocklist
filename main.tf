/**
 * # terraform-cloudflare-tailscale-blocklist
 *
 * Terraform module for deploying a Cloudflare blocklist on Tailscale exit nodes.
 *
 * > [!WARNING]\
 * > Cloudflare Zero Trust (CZT) expects a default location to exist at all times. First, manually create an empty CZT default location before working with this module.
 *
 * ## References
 *
 * https://blog.marcolancini.it/2022/blog-serverless-ad-blocking-with-cloudflare-gateway/
 * https://community.cloudflare.com/t/adding-multiple-lists-to-cloudflare-zerotrust-dns-policy/497393/3
 * https://icloudgo.net/posts/block-ads-with-cloudflare-zero-trust/
 *
 */

data "http" "blocklist_url" {
  url = "https://scripttiger.github.io/alts/reduced/blacklist.txt"
}

locals {
  # Split on newlines, remove carriage returns, and remove empty lines
  blocklist_raw_lines = compact(split("\n", replace(data.http.blocklist_url.response_body, "\r", "")))

  # Remove lines that begin with #
  blocklist = [
    for line in local.blocklist_raw_lines : line if !startswith(line, "#")
  ]

  # Create a list of lists, with a maximum of 1000 items per nested list
  blocklist_chunks = [
    for i in range(0, length(local.blocklist), 1000) :
    slice(local.blocklist, i, i + min(length(local.blocklist) - i, 1000))
  ]

  blocklist_map = {
    for idx, val in local.blocklist_chunks : tostring(idx) => val
  }

  # Build the wirefilter expression to be used with the DNS policy
  rule_traffic_expression = join(" or ", [
    for list in cloudflare_teams_list.blocklist : "any(dns.domains[*] in ${"$"}${list.id})"
  ])
}

resource "cloudflare_teams_list" "blocklist" {
  for_each   = local.blocklist_map
  account_id = var.cloudflare_account_id
  name       = "domain-blocklist-${each.key}"
  type       = "DOMAIN"
  items      = each.value
}

resource "cloudflare_teams_rule" "blocklist_policy" {
  account_id  = var.cloudflare_account_id
  name        = "advertisements"
  description = "Block advertisements"
  enabled     = true
  precedence  = 1
  action      = "block"
  filters = [
    "dns"
  ]
  traffic = "any(dns.content_category[*] in {66 85}) or ${local.rule_traffic_expression}"
}

resource "cloudflare_teams_rule" "security_policy" {
  account_id  = var.cloudflare_account_id
  name        = "security"
  description = "Block security risks and threats"
  enabled     = true
  precedence  = 2
  action      = "block"
  filters = [
    "dns"
  ]
  traffic = "any(dns.content_category[*] in {32 85 170}) or any(dns.security_category[*] in {178 80 83 176 117 131 134 151 153})"
}

resource "cloudflare_teams_location" "this" {
  account_id     = var.cloudflare_account_id
  name           = "tailscale-exit-nodes"
  client_default = false

  dynamic "networks" {
    for_each = var.public_ip_address

    content {
      network = "${networks.value}/32"
    }
  }
}

resource "tailscale_dns_nameservers" "this" {
  nameservers = [
    var.cloudflare_dns_resolvers_ipv4[0],
    var.cloudflare_dns_resolvers_ipv4[1],
    cloudflare_teams_location.this.ip
  ]
}
