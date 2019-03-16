module "proxy-worker" {
  source = "../terraform_modules/cloudflare_zone"

  domain_name = "${var.proxy_domain}"
}

module "blue-worker" {
  source = "../terraform_modules/cloudflare_zone"

  domain_name = "${var.blue_domain}"
}

module "green-worker" {
  source = "../terraform_modules/cloudflare_zone"

  domain_name = "${var.green_domain}"
}

# Domain names
output "proxy_domain" {
  value = "${var.proxy_domain}"
}

output "blue_domain" {
  value = "${var.blue_domain}"
}

output "green_domain" {
  value = "${var.green_domain}"
}

output "default_origin" {
  value = "${var.default_origin}"
}

# Zone ids
output "proxy-worker_zone_id" {
  value = "${module.proxy-worker.zone_id}"
}

output "green-worker_zone_id" {
  value = "${module.green-worker.zone_id}"
}

output "blue-worker_zone_id" {
  value = "${module.blue-worker.zone_id}"
}

# Nameservers
output "proxy-worker_name_servers" {
  value = "${module.proxy-worker.name_servers}"
}

output "blue-worker_name_servers" {
  value = "${module.blue-worker.name_servers}"
}

output "green-worker_name_servers" {
  value = "${module.green-worker.name_servers}"
}
