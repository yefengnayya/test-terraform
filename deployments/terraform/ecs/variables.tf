variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "app_name" {
  type = string
  default = "nayya-ins"
}

variable "image" {
  type = string
}

variable "use_blue_green" {
  type = bool
}

variable "command" {
  type = list(string)
  default = null
}

variable "entrypoint" {
  type = list(string)
  default = null
}

variable "domain" {
  type = string
}

variable "certificate_id" {
  type = string
}

variable "datadog_api_key" {
  type      = string
  sensitive = true
}

variable "tags" {
  type = map(string)
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "desired_capacity" {
  type = number
}

variable "commit_hash" {
  type = string
}
