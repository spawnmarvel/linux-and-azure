# Bicep Linux VM using Powershell

## Best practices for Bicep

* Parameters
* Good naming
* Think carefully about the parameters your template uses.
* Be mindful of the default values you use.

Read more:

https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices

## Quickstart: Create an Ubuntu Linux virtual machine using a Bicep file and Powershell

Read more:

https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-bicep?tabs=PowerShell

## Quickstart: Create Bicep files with Visual Studio Code

Read more:

https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/quickstart-create-bicep-use-visual-studio-code?tabs=azure-cli

## Use ps1 scripts

```ps1
Connect-AzAccount -TenantId The-tenant-id-we-copied-from-azure-ad

```

* deploy.ps1
* remove.ps1
* manual_reset_user.ps1, Go to Portal->VM->Help->Reset password
* verify.ps1
* TODO the others


az-ps1 and cli reference https://follow-e-lo.com/azure-tips-for-test-vms/

SSH to Linux VM

```bash
ssh user@ip-address

```

## Learn modules for Bicep

* You have done many, log in and do them again and do the rest also.
* Skip th CI/CD is much cost, focus on fundamentals and deployments script for configuration of apps.

### Build your first Bicep template TBD

### Part 1: Fundamentals of Bicep TBD

### Part 2: Intermediate Bicep TBD

### Part 3: Advanced Bicep TBD

#### Extend Bicep and ARM templates using deployment scripts

https://learn.microsoft.com/en-us/training/modules/extend-resource-manager-template-deployment-scripts/

All Learn modules for Bicep

https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/learn-bicep


## Use deployment stacks tbd

### Introduction to deployment stacks

### Build your first deployment stack

### Manage resource lifecycles with deployment stacks

## Bicep resource definition; Microsoft.Compute virtualMachines

https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep

# Misc

## Virtual machine extensions and features for Linux

Read more:

https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/features-linux?source=recommendations&tabs=azure-cli

## Linux extensions for Microsoft Azure IaaS

* Custom Script
* DSC
* OS Patching
* VM Access
* OMS Agent
* Diagnostic
* Backup

Read more:

https://github.com/Azure/azure-linux-extensions

## 32 results for "bicep"

https://learn.microsoft.com/en-us/training/browse/?terms=bicep&source=learn