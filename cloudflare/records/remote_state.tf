data "terraform_remote_state" "base" {
  backend = "local"

  config = {
    path = "${path.module}/../terraform.tfstate"
  }
}
