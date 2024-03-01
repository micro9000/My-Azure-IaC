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

variable "azure-do-agent-pool-name" {
  type = string
}

variable "azure-do-project-name" {
  type = string
}