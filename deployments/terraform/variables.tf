variable "app_name" {
  type = string

  validation {
    condition     = can(regex("^[a-z-]+$", var.app_name)) && length(var.app_name) <= 16
    error_message = "The app_name value must only contain lowercase letters and hyphens and must not be longer than 16 characters."
  }
}

variable "environment" {
  type = string

  validation {
    condition     = length(var.environment) <= 6
    error_message = "The environment value must not be longer than 6 characters."
  }
}

variable "domain" {
  type = string
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

variable "image" {
  type = string
}

variable "use_blue_green" {
  type = bool
}

variable "datadog_api_key" {
  sensitive = true
  type = string
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "certificate_id" {
  type = string
  default = "6940e010-aca9-43a8-91d1-39368606db87" # this is the ACM cert ID for *.nayya.com
}

variable "commit_hash" {
  type = string
}
