resource "cloudflare_zone" "zone" {
  zone = "${var.domain_name}"
  plan = "${var.cloudflare_plan}"
}

output "zone_id" {
  value = "${cloudflare_zone.zone.id}"
}

output "name_servers" {
  value = "${cloudflare_zone.zone.name_servers}"
}
