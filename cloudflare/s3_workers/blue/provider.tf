provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}

provider "aws" {
  region = "us-east-1"
}
