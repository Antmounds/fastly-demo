# Configure remote state
terraform {
  required_version = ">=0.12.26"

  backend "s3" {
    bucket = "antmounds"
    key    = "terraform-state/fastly-demo.tfstate"
    region = "us-east-1"
    # encrypt = true
  }
}

# Configure the Fastly Provider
provider "fastly" {
  # api_key = var.fastly_key # Set via FASTLY_API_KEY environment variable
}

resource "fastly_service_v1" "demo" {
  name            = var.app_name
  comment         = "Testing out fastly for loadbalancing between intra/inter-cloud hosts - Managed by Terraform"
  version_comment = "trying to get healthchecks setup"

  domain {
    name    = var.domain_name
    comment = "wildcard is supported i.e. ${var.domain_name}"
  }

  backend {
    address     = element(aws_eip.app_ip.*.public_ip, 0)
    name        = element(aws_eip.app_ip.*.instance, 0)
    port        = 80
    healthcheck = "global-health-check"
  }

  backend {
    address     = element(aws_eip.app_ip.*.public_ip, 1)
    name        = element(aws_eip.app_ip.*.instance, 1)
    port        = 80
    healthcheck = "global-health-check"
  }

  healthcheck {
    name              = "global-health-check"
    host              = var.domain_name
    path              = "/index.html"
    check_interval    = 60000
    expected_response = 200
    method            = "GET"
  }

  force_destroy = false
}

variable "app_name" {
  type        = string
  default     = "fastly-demo"
  description = "Name of this service"
}

variable "domain_name" {
  type        = string
  default     = ""
  description = "Domain name used as the root for Fastly services"
}

variable "key_name" {
  type        = string
  default     = ""
  description = "SSH key name for connecting to instances"
}

variable "owner" {
  type        = string
  default     = ""
  description = "Email address of service owner"
}