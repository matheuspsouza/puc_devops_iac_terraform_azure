# Create network interface
resource "azurerm_network_interface" "my_vm_nic" {
  count               = var.vm_count
  name                = "${var.vm_network_interface_name_prefix}${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "nicVm${count.index}Configuration"
    subnet_id                     = azurerm_subnet.my_backend_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Adiciona as VMs no Address pool
resource "azurerm_network_interface_backend_address_pool_association" "my_nic_vm_addresspool" {
  count                   = var.vm_count
  network_interface_id    = azurerm_network_interface.my_vm_nic[count.index].id
  ip_configuration_name   = "nicVm${count.index}Configuration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.my_backend_pool.id
}

# Criar grupo de seguranca de rede e regra
resource "azurerm_network_security_group" "my_nsg" {
  name                = "myNSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name                       = "myNSGRuleHTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Conecta NSG com as VMs
resource "azurerm_network_interface_security_group_association" "net_nsg_vm" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.my_vm_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.my_nsg.id
}

# Gera texto randomico para storage
resource "random_id" "random_vm_id" {
  count = var.vm_count
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }
  byte_length = 8
}

resource "azurerm_storage_account" "my_vm_storage_account" {
  count                    = var.vm_count
  name                     = "diag${random_id.random_vm_id[count.index].hex}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Cria VMs
resource "azurerm_linux_virtual_machine" "my_vm" {
  count                 = var.vm_count
  name                  = "${var.vm_name_prefix}${count.index}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.my_vm_nic[count.index].id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "${var.vm_name_prefix}${count.index}OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "vm${count.index}"
  admin_username = var.username

  admin_ssh_key {
    username   = var.username
    public_key = azapi_resource_action.ssh_public_key_gen.output.publicKey
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_vm_storage_account[count.index].primary_blob_endpoint
  }

  depends_on = [
    azurerm_network_interface.my_vm_nic,
    azurerm_storage_account.my_vm_storage_account,
    azapi_resource_action.ssh_public_key_gen
  ]
}
