data "terraform_remote_state" "base" {
  backend = "local"

  config = {
    path = "${path.module}/../../terraform.tfstate"
  }
}

data "terraform_remote_state" "s3_bucket" {
  backend = "local"

  config = {
    path = "${path.module}/../../aws_s3_bucket/terraform.tfstate"
  }
}
