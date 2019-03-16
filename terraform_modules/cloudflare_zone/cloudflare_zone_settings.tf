resource "cloudflare_zone_settings_override" "zone_settings" {
  name = "${var.domain_name}"

  settings {
    always_use_https = "on"

    # this is required to allow SSL access to AWS API Gateway
    ssl = "full"
  }

  depends_on = ["cloudflare_zone.zone"]
}
