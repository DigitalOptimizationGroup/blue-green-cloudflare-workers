resource "cloudflare_record" "cf_record" {
  domain  = "${var.cloudflare_zone}"
  name    = "${var.record_name}"
  value   = "${var.record_value}"
  type    = "${var.record_type}"
  proxied = true
}
