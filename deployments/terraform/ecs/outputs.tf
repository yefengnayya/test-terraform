output "task_definition_arn" {
  value = module.service.task_definition_arn
}

output "container_name" {
  value = module.service.container_name
}

output "container_port" {
  value = module.service.container_port
}

output "application_name" {
  value = module.service.application_name
}

output "deployment_group_name" {
  value = module.service.deployment_group_name
}
