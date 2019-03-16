# this get's the given release from s3
data "aws_s3_bucket_object" "blue_worker" {
  bucket = "${data.terraform_remote_state.s3_bucket.buckets.private_bucket}"
  key    = "${var.worker_s3_key}"
}

module "blue_worker" {
  source = "../../../terraform_modules/cloudflare_worker"

  zone_domain = "${data.terraform_remote_state.base.blue_domain}"
  content     = "${data.aws_s3_bucket_object.blue_worker.body}"
}
