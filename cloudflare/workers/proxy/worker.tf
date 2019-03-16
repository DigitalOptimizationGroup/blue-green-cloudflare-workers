module "proxy_worker" {
  source = "../../../terraform_modules/cloudflare_worker"

  zone_domain = "${data.terraform_remote_state.base.proxy_domain}"
  content     = "${file("../../../dist/worker_proxy.js")}"
}
