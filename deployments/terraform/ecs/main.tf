data "aws_caller_identity" "current" {}

data "aws_vpc" "target_vpc" {
  tags = {
    Environment = var.environment
    Terraform = true
  }
}

locals {
  secret_vars = [
    # This is an array for the names of ENV vars
  ]

  account_id = data.aws_caller_identity.current.account_id

  ssm_prefix = "arn:aws:ssm:${var.region}:${local.account_id}:parameter/${var.app_name}.${var.environment}"

  certificate_arn = var.certificate_id != "" ? "arn:aws:acm:${var.region}:${data.aws_caller_identity.current.account_id}:certificate/${var.certificate_id}" : ""

  container_port = 5050
}

module "service" {
  source        = "s3::https://s3-us-east-1.amazonaws.com/nayya-terraform-state/shared-infra-repo-0.3.5.tar.gz//modules/aws/ecs/deployment"

  name                   = var.app_name
  environment            = var.environment
  cluster_name           = var.environment
  region                 = var.region
  vpc_id                 = data.aws_vpc.target_vpc.id

  public_subnet          = false
  is_internal            = false
  create_dns             = var.domain != ""
  create_alb             = var.domain != ""
  use_blue_green         = var.use_blue_green
  domain                 = var.domain
  container_port         = local.container_port
  desired_capacity       = var.desired_capacity
  task_cpu               = var.cpu
  task_memory            = var.memory
  certificate_arn        = local.certificate_arn
  test_traffic_port      = 8433
  enable_execute_command = true

  container_definitions = [
    {
      name       = var.app_name
      image      = var.image
      essential  = true
      portMappings = [{ containerPort = local.container_port }]
      environment = [
        {
          name = "PORT"
          value = tostring(local.container_port)
        },
        {
          name = "COMMIT_HASH"
          value = var.commit_hash
        }
      ]
      secrets    = [for v in local.secret_vars:
        {
          name = v
          valueFrom = "${local.ssm_prefix}.${v}"
        }
      ]
    },
    {
      name = "datadog-agent"
      image = "datadog/agent:latest"
      environment = [
        {
          name = "DD_API_KEY",
          value = var.datadog_api_key
        },
        {
          "name": "ECS_FARGATE",
          "value": "true"
        }
      ]
    }
  ]

  tags = var.tags
}
