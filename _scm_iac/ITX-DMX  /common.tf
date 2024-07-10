terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "EMEA"
  ignore_tags {
    key_prefixes=["vpcx-"]
  }
}

variable "IAC_org" { type = string }
