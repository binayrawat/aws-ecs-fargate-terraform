terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Bucket and region come from -backend-config (see README / CI), so no account
  # details are committed. S3-native locking replaces the old DynamoDB lock table.
  backend "s3" {
    key          = "dev/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
      Repository  = "github.com/binayrawat/aws-ecs-fargate-terraform"
    }
  }
}

locals {
  name = "${var.project}-${var.environment}"
}

data "aws_ecr_repository" "app" {
  name = var.project
}

module "network" {
  source = "../../modules/network"

  name               = local.name
  cidr_block         = var.vpc_cidr
  enable_nat_gateway = var.enable_nat_gateway
}

module "service" {
  source = "../../modules/ecs-service"

  name   = local.name
  region = var.region
  vpc_id = module.network.vpc_id

  public_subnet_ids = module.network.public_subnet_ids
  # Without NAT, private subnets have no route to ECR, so tasks run in public
  # subnets with a public IP. Their security group still only admits the ALB.
  app_subnet_ids   = var.enable_nat_gateway ? module.network.private_subnet_ids : module.network.public_subnet_ids
  assign_public_ip = !var.enable_nat_gateway

  image = "${data.aws_ecr_repository.app.repository_url}:${var.image_tag}"

  cpu          = 256
  memory       = 512
  min_capacity = 1
  max_capacity = 3

  certificate_arn = var.certificate_arn

  environment = {
    APP_ENV = var.environment
  }
}
