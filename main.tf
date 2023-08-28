provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "example-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_service_plan" "example" {
  name                = "example-serviceplan" 
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Windows"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "example" {
  name                = "my-unique-appname"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  service_plan_id     = azurerm_service_plan.example.id

  site_config {}

  app_settings = {
    "SOME_KEY" = "some-value" 
  }
}

resource "azurerm_linux_web_app_slot" "example-staging" {
  name           = "example-slot"
  app_service_id = azurerm_linux_web_app.example.id

  site_config {}
}

resource "azurerm_app_service_slot_virtual_network_swift_connection" "example" {
  slot_name      = azurerm_linux_web_app_slot.example-staging.name
  app_service_id = azurerm_linux_web_app.example.id
  subnet_id      = azurerm_subnet.example.id
}
