variable "resource_group_name_prefix" {
  type = string
  default = "akscluster"
}

variable "location" {
  type = "string"
  description = "The spokes's regional affinity, must be the same as the hub's location. All resources tied to this spoke will also be homed in this region. The network team maintains this approved regional list which is a subset of zones with Availability Zone support."
}

# Hub Resource names
variable "hub_resource_group_name" {
  type = string
}

variable "hub_vnet_name" {
  type = string
}

variable "hub_firewall_name" {
  type = string
}

variable "hub_workspace" {
  type = string
}