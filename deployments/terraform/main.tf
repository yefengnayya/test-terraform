provider "aws" {
  region  = "us-east-1"
}

locals {
  tags = {
    Terraform   = true
    AppName     = var.app_name
    Environment = var.environment
  }
}

module "ecs" {
  source = "./ecs"

  region           = var.region
  environment      = var.environment
  image            = var.image
  domain           = var.domain
  datadog_api_key  = var.datadog_api_key
  use_blue_green   = var.use_blue_green
  cpu              = var.cpu
  memory           = var.memory
  desired_capacity = var.desired_capacity
  app_name         = var.app_name
  tags             = local.tags
  commit_hash      = var.commit_hash

  certificate_id    = var.certificate_id
}

module "trigger_codedeploy" {
  source = "./trigger_codedeploy"
  count  = var.use_blue_green ? 1 : 0

  application_name      = module.ecs.application_name
  deployment_group_name = module.ecs.deployment_group_name
  task_definition_arn   = module.ecs.task_definition_arn
  container_name        = module.ecs.container_name
  container_port        = module.ecs.container_port
}
