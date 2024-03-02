# Instructions

The resources that we are going to create using the following commands are the initial Azure resources that we need in our Azure DevOps Organization

## Manually Created Resources

## Initial Image

Generate the initial image using the following commands, replace the subscription id,
This will generate an Image and an Azure Image resource contains that generated image

`.\Initial-Image.ps1 -subscriptionId "<subscription_id>" -resourceGroupName "<resource_group_name>" -imageType "Ubuntu2204" -azureLocation "East Asia"`

## Terraform Remote State Storage

Provision the storage account that we will use as Backend storage for TF state

```bash
./Initial-Storage-Account.sh --resource-group-name TerraformBackendRG --location eastasia --storage-account-name tfbackend02242024 --container-name terraform-states --storage-account-sku Standard_LRS
```
