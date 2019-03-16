module "base" {
  source      = "../../terraform_modules/s3_bucket"
  bucket_name = "${var.bucket_name}"
  versioning  = "${var.versioning}"
}

output "buckets.private_bucket_domain_name" {
  value = "${module.base.buckets.private_bucket_domain_name}"
}

output "buckets.private_bucket" {
  value = "${module.base.buckets.private_bucket}"
}

output "buckets.private_bucket_arn" {
  value = "${module.base.buckets.private_bucket_arn}"
}
