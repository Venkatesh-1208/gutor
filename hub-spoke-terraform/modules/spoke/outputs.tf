output "vnet_id" {
  value = azurerm_virtual_network.spoke.id
}

output "vnet_name" {
  value = azurerm_virtual_network.spoke.name
}

output "resource_group_name" {
  value = azurerm_resource_group.spoke.name
}

output "workload_subnet_id" {
  value = azurerm_subnet.workload.id
}

output "vm_private_ips" {
  value = [for nic in azurerm_network_interface.vm : nic.private_ip_address]
}

output "vm_ids" {
  value = [for vm in azurerm_linux_virtual_machine.vm : vm.id]
}
