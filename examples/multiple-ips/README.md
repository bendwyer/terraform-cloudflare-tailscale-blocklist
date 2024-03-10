# Multiple IPs

This example will download a reduced FQDN blocklist which is then uploaded to Cloudflare and used to build a gateway firewall policy. Multiple source IPs are associated with a Cloudflare DNS location to enable dns query filtering, and the Tailscale DNS settings are updated so that traffic is sent to Cloudflare.
