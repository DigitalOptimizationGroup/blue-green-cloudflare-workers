module "blue_worker" {
  source = "../../../terraform_modules/cloudflare_worker"

  zone_domain = "${data.terraform_remote_state.base.blue_domain}"
  content     = "${file("../../../dist/worker.js")}"
}
