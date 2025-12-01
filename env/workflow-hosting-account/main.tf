terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = var.home_region
  default_tags {
    tags = { Project = "aws-eventbridge-ssm-automation-setters" }
  }
}

data "aws_caller_identity" "current" {}

locals {
  account_id            = data.aws_caller_identity.current.account_id
  region                = var.home_region
  target_execution_role = "AutomationSettersTargetExecutionRole"
}
