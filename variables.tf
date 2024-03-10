variable "cloudflare_account_id" {
  description = "Cloudflare account ID."
  type        = string
}

variable "cloudflare_dns_resolvers_ipv4" {
  default = [
    "172.64.36.1",
    "172.64.36.2"
  ]
  description = "For queries over IPv4, the default DNS resolver IP addresses are anycast IP addresses, and they are shared across every Cloudflare Zero Trust account. See https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/agentless/dns/locations/dns-resolver-ips/#ipv4-address for more information."
  type        = list(string)
}

variable "public_ip_address" {
  description = "A set of public IP address(es) where Cloudflare Gateway will be enabled."
  type        = set(string)
}
