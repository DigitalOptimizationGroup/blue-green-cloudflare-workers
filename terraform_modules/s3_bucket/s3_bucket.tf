/**/

resource "aws_s3_bucket" "private_bucket" {
  bucket        = "${var.bucket_name}"
  acl           = "private"
  force_destroy = false

  versioning {
    enabled = "${var.versioning}"
  }
}

output "buckets.private_bucket_domain_name" {
  value = "${aws_s3_bucket.private_bucket.bucket_domain_name}"
}

output "buckets.private_bucket" {
  value = "${aws_s3_bucket.private_bucket.id}"
}

output "buckets.private_bucket_arn" {
  value = "${aws_s3_bucket.private_bucket.arn}"
}
