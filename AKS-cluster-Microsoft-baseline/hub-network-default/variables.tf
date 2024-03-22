variable "prefix" {
  type = string
  default = "hubnetwork"
}
variable "resource_group_name" {
  type = string
  default = "hub_resource_group"
}

variable "location" {
  type = string
  default = "East Asia"
  description = "The hub's regional affinity. All resources tied to this hub will also be homed in this region. The network team maintains an approved regional list which is a subset of zones with Availability Zone support. Defaults to the resource group's location for higher availability."
}

variable "hubVirtualNetworkAddressSpace" {
  type = string
  default = "10.200.0.0/24"
  description = "Optional. A /24 to contain the regional firewall, management, and gateway subnet. Defaults to 10.200.0.0/24"
}

variable "hubVirtualNetworkAzureFirewallSubnetAddressSpace" {
  type = string
  default = "10.200.0.0/26"
  description = "Optional. A /26 under the virtual network address space for the regional Azure Firewall. Defaults to 10.200.0.0/26"
}

variable "hubVirtualNetworkGatewaySubnetAddressSpace" {
  type = string
  default = "10.200.0.64/27"
  description = "Optional. A /27 under the virtual network address space for our regional On-Prem Gateway. Defaults to 10.200.0.64/27"
}

variable "hubVirtualNetworkBastionSubnetAddressSpace" {
  type = string
  default = "10.200.0.128/26"
  description = "Optional. A /26 under the virtual network address space for regional Azure Bastion. Defaults to 10.200.0.128/26"
}