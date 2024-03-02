# This script is intended to run manually either in your local development machine or Azure VM
param(
    [string]$subscriptionId,
    [string]$resourceGroupName

    [Parameter(Mantory=$true)]
    [ValidateSet("Windows2022", "Ubuntu2204")]
    [string]$imageType

    [string]$azureLocation
)
$temporaryDirectory = "C:\AzureDevOpsRunnerImagesRepo"

# Delete the directory and its contents
Remove-Item -Path $temporaryDirectory -Recurse -Force

# Create a new directory
New-Item -ItemType Directory -Path $temporaryDirectory
Set-Location -Path $temporaryDirectory

# These commands are based on this repo: https://github.com/actions/runner-images/blob/main/docs/create-image-and-azure-resources.md

# Clone the repository
git clone https://github.com/actions/runner-images.git

# Set the working directory
Set-Location runner-images

# Import the module
Import-Module .\helpers\GenerateResourcesAndImage.ps1

# Generate resources and image
GenerateResourcesAndImage -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroupName -ImageType $imageType -AzureLocation $azureLocation

