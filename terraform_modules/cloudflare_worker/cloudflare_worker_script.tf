resource "cloudflare_worker_script" "my_script" {
  zone    = "${var.zone_domain}"
  content = "${var.content}"
}

resource "cloudflare_worker_route" "my_route" {
  zone    = "${var.zone_domain}"
  pattern = "${var.zone_domain}/*"
  enabled = true

  # it's recommended to set `depends_on` to point to the cloudflare_worker_script
  # resource in order to make sure that the script is uploaded before the route
  # is created
  depends_on = ["cloudflare_worker_script.my_script"]
}
