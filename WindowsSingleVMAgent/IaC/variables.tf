variable "vm_computer_name" {
  type = string
}

variable "vm_admin_username" {
  type = string
}

variable "vm_admin_password" {
  type      = string
  sensitive = true
}

variable "azure_do_agent_pool_name" {
  type = string
}

variable "azure_do_project_name" {
  type = string
}