# Function to log information to a file
# Function to append to the log file
function Write-Log {
    param(
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $Message"
    $logFile = "../log.txt"
    Add-Content -Path $logFile -Value $logEntry
}

# Get the current date and log it
$now = Get-Date
Write-Output $now
Write-Log -Message $now

# Generate a simple VM name with a random number
$simpleVmName = "Vm-test123it" # "Vm-$(Get-Random)"
$resourceGroup = "Rg-iac-deploy-linux-fun-12"
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
Write-Log -Message $resourceGroup
Write-Log -Message $adminU
Write-Log -Message $simpleVmName

# Reference: https://github.com/Azure/azure-cli/issues/25710
# Disable using binary from path for Bicep
# az config set bicep.use_binary_from_path=False

# Create the resource group with specified location and tags
New-AzResourceGroup -Name $resourceGroup -Location $location -Tag $tags -Force


# Deploy all resources in the resource group with no data disk to an existing VNet

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile "../templates/main_vm_extern_vnet.bicep" `
    -vmName $simpleVmName `
    -adminUsername $adminU `
    -resourceGroupVnetName $rgVnetName `
    -virtualNetworkName $vnet `
    -subnetName $subnet `
    -WhatIf


