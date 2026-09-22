data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "acme"
    workspaces = {
      name = "network-dev"
    }
  }
}

data "terraform_remote_state" "security" {
  backend = "remote"

  config = {
    organization = "acme"
    workspaces = {
      name = "security-dev"
    }
  }
}

data "terraform_remote_state" "infra_common_s3" {
  backend = "remote"

  config = {
    organization = "acme"
    workspaces = {
      name = "acme-infra-common-s3-dev"
    }
  }
}
