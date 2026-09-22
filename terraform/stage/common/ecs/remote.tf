data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "acme"
    workspaces = {
      name = "network-prod"
    }
  }
}

data "terraform_remote_state" "infra_common_alb" {
  backend = "remote"

  config = {
    organization = "acme"
    workspaces = {
      name = "acme-infra-common-alb-stage"
    }
  }
}
