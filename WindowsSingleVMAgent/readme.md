# Description

This will provision the following in Azure:

1. Windows Virtual Machine 2022 (Using the generated GitHub Actions Runner Image)
2. Storage account for VM diagnostic
3. VNet components
4. VM Extension CustomScriptExtension and run the PowerShell script to install and run the Azure DevOps Agent

And the following resources in Azure DevOps

1. Agent Pool that will automatically added to a project

