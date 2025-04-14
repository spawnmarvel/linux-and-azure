# Bicep Linux VM using Powershell

When picking the right tool, consider your past experience and current work environment.

* Azure CLI syntax is similar to that of Bash scripting. If you work primarily with Linux systems, Azure CLI feels more natural.
* Azure PowerShell is a PowerShell module. If you work primarily with Windows systems, Azure PowerShell is a natural fit. 
* * Commands follow a verb-noun naming scheme and data is returned as objects.

With that said, being open-minded will only improve your abilities. Use a different tool when it makes sense.

https://learn.microsoft.com/en-us/cli/azure/choose-the-right-azure-command-line-tool


## Best practices for Bicep

* Parameters
* Good naming
* Think carefully about the parameters your template uses.
* Be mindful of the default values you use.

Read more:

https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices


You can also look or export templates.

VM | Automation -> Export template -> Bicep 

Understanding and Using Project BICEP - The NEW Azure Deployment Technology

https://www.youtube.com/watch?v=_yvb6NVx61Y

## Install Bicep tools

https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#install-manually

## Quickstart: Create an Ubuntu Linux virtual machine using a Bicep file and Powershell

Read more:

https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-bicep?tabs=PowerShell

## Quickstart: Create Bicep files with Visual Studio Code

Read more:

https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/quickstart-create-bicep-use-visual-studio-code?tabs=azure-cli

## Use ps1 scripts (but example in both for connect)

Powershell

```ps1
Connect-AzAccount -TenantId The-tenant-id-we-copied-from-azure-ad

```
* deploy.ps1, does it work, else fix it = Y/N
* deploy_remove.ps1, does it work, else fix it = Y/N
* deploy_manual_reset_user.ps1, Go to Portal->VM->Help->Reset password, or make az cli for this
* deploy_verify.ps1, does it work, else fix it = Y/N
* deploy_autoshutdown.ps1, does it work, else fix it = Y/N

Bash

```bash
az login --tenant The-tenant-id-we-copied-from-azure-ad
```

az-ps1 and cli reference https://follow-e-lo.com/azure-tips-for-test-vms/

SSH to Linux VM

```bash
ssh user@ip-address

```

## Learn modules for Bicep

You have done many, log in and do them again or just read to make notes.

Skip the CI/CD is much cost, focus on fundamentals and deployments script for configuration of apps.

* Build your first Bicep template TBD
* Part 1: Fundamentals of Bicep TBD
* Part 2: Intermediate Bicep TBD
* Part 3: Advanced Bicep TBD

All Learn modules for Bicep

https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/learn-bicep

### Extend Bicep and ARM templates using deployment scripts TODO

To test the script

* Either run it on the vm 
* or, run it outside the vm first, use vm | Operations -> Run command -> RunShellScript

Focus on this one, see if you can use ps1 with bicep and the custom script extension for Linux and call a bash script.

Add custom steps to your Bicep or JSON Azure Resource Manager templates (ARM templates). Integrate deployment scripts with your deployment by using parameters and outputs.

https://learn.microsoft.com/en-us/training/modules/extend-resource-manager-template-deployment-scripts/

Custom script extension 1, inline

```json
// install something easy inline
```

Custom script extension 2, https on github

```json
// install something easy remote script
```
Use the Azure Custom Script Extension Version 2 with Linux virtual machines

https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux

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