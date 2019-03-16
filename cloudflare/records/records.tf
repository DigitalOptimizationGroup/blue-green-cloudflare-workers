module "proxy-worker_record" {
  source = "../../terraform_modules/cloudflare_record"

  cloudflare_zone = "${data.terraform_remote_state.base.proxy_domain}"
  record_name     = "${data.terraform_remote_state.base.proxy_domain}"
  record_type     = "CNAME"
  record_value    = "${data.terraform_remote_state.base.default_origin}"
}

module "blue-worker_record" {
  source = "../../terraform_modules/cloudflare_record"

  cloudflare_zone = "${data.terraform_remote_state.base.blue_domain}"
  record_name     = "${data.terraform_remote_state.base.blue_domain}"
  record_type     = "CNAME"
  record_value    = "${data.terraform_remote_state.base.default_origin}"
}

module "green-worker_record" {
  source = "../../terraform_modules/cloudflare_record"

  cloudflare_zone = "${data.terraform_remote_state.base.green_domain}"
  record_name     = "${data.terraform_remote_state.base.green_domain}"
  record_type     = "CNAME"
  record_value    = "${data.terraform_remote_state.base.default_origin}"
}
