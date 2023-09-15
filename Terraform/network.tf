resource "azurerm_virtual_network" "vnet" {
    name                = "AppNetwork"
    address_space       = ["10.0.0.0/16"]
    location            = local.RGLocation
    resource_group_name = local.RGName

    depends_on = [ azurerm_resource_group.rg ]
}

resource "azurerm_subnet" "vnet_subnet" {
    name                 = "appSubnet"
    resource_group_name  = local.RGName
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.1.0/24"]

    delegation {
        name = "example-delegation"

        service_delegation {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
    }

    depends_on = [ azurerm_virtual_network.vnet ]
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnet_connection" {    
    app_service_id = azurerm_linux_web_app.WebApp.id
    subnet_id      = azurerm_subnet.vnet_subnet.id

    depends_on = [ azurerm_subnet.vnet_subnet, azurerm_linux_web_app.WebApp ]
}
