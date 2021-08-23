resource "null_resource" "trigger-deployment" {
  provisioner "local-exec" {
    command = "${path.module}/script.sh"

    environment = {
      APPLICATION_NAME             = var.application_name
      CONTAINER_NAME               = var.container_name
      CONTAINER_PORT               = var.container_port
      DEPLOYMENT_GROUP_NAME        = var.deployment_group_name
      TASK_DEFINITION_ARN          = var.task_definition_arn
    }
  }

  triggers = {
    APPLICATION_NAME             = var.application_name
    CONTAINER_NAME               = var.container_name
    CONTAINER_PORT               = var.container_port
    DEPLOYMENT_GROUP_NAME        = var.deployment_group_name
    TASK_DEFINITION_ARN          = var.task_definition_arn
  }
}
