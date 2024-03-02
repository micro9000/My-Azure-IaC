#!/bin/bash

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --resource-group-name)
            resourceGroupName="$2"
            shift
            ;;
        --location)
            location="$2"
            shift
            ;;
        --storage-account-name)
            storageAccountName="$2"
            shift
            ;;
        --container-name)
            containerName="$2"
            shift
            ;;
        --storage-account-sku)
            storageAccountSku="$2"
            shift
            ;;
        *)
            echo "Invalid argument: $1"
            exit 1
            ;;
    esac
    shift
done

# Check if required arguments are provided
if [[ -z $resourceGroupName || -z $location || -z $storageAccountName || -z $containerName || -z $storageAccountSku ]]; then
    echo "Usage: $0 --resource-group-name <name> --location <location> --storage-account-name <name> --container-name <name> --storage-account-sku <sku>"
    exit 1
fi

# Create resource group
az group create --name $resourceGroupName --location $location

# Create storage account
az storage account create \
          --name $storageAccountName \
          --resource-group $resourceGroupName \
          --location $location \
          --sku $storageAccountSku \
          --https-only true \
          --kind StorageV2 \
          --allow-blob-public-access false

# Create storage container
az storage container create \
          --name $containerName \
          --account-name $storageAccountName \
          --auth-mode login
