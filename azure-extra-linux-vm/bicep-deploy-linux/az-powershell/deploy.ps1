# Function to log information to a file
function Log-Information {
    param (
        [string]$Message
    )
    $logFile = "deploylog.txt"
    Add-Content -Path $logFile -Value $Message
}

# Get the current date and log it
$now = Get-Date
Write-Output $now
Log-Information -Message $now

# Generate a simple VM name with a random number
$simpleVmName = "Vm-test123it" # "Vm-$(Get-Random)"
$resourceGroup = "Rg-iac-linux-fu-0991"
$location = "uksouth"
$tags = @{Environment = "Qa" }

# Read credentials from key vault file
$fileName = "keyvault.txt"
$myArray = Get-Content -Path $fileName
$adminU = $myArray[0]
$adminP = $myArray[1]
$rgVnetName = "Rg-vnet-uks-central"
$vnet = "vnet-uks-central"
$subnet = "Vms03"

# Output admin username and VM name
Write-Output $adminU
Write-Output $simpleVmName

# Log resource group and admin information
Log-Information -Message $resourceGroup
Log-Information -Message $adminU
Log-Information -Message $simpleVmName

# Reference: https://github.com/Azure/azure-cli/issues/25710
# Disable using binary from path for Bicep
# az config set bicep.use_binary_from_path=False

# Create the resource group with specified location and tags
New-AzResourceGroup -Name $resourceGroup -Location $location -Tag $tags -Force


# Deploy all resources in the resource group with no data disk to an existing VNet

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile ../main_deploy_vm_no_extra_disk_to_outside_vnet.bicep `
    -vmName $simpleVmName `
    -adminUsername $adminU `
    -resourceGroupVnetName $rgVnetName `
    -virtualNetworkName $vnet `
    -subnetName $subnet `
    # -WhatIf
