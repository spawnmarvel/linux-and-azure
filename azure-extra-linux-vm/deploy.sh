#!/bin/bash



logInformation() {
    logFile='deploylog.txt'
    echo $1 >> $logFile
}

now=$(date)
echo $now
logInformation $now

simpleVmName="Vm-$RANDOM"
resourceGroup='Rg-iac-linux-fu-0991'
location='uksouth'
tags='Environment=Qa'

fileName='keyvault.txt'
readarray myArray < $fileName
adminU=${myArray[0]}
adminP=${myArray[1]}
rgVnetName='Rg-vnet-uks-central'
vnet='vnet-uks-central'
subnet='Vms03'

echo $adminU
echo $simpleVmName

logInformation $resourceGroup
logInformation $adminU
logInformation $simpleVmName

# https://github.com/Azure/azure-cli/issues/25710
# az config set bicep.use_binary_from_path=False

az group create --location $location --name $resourceGroup --tags $tags

# Deploy all in on rg with data disk
# az deployment group create --name mainDep --resource-group $resourceGroup --template-file main_deploy_vm.bicep --parameters vmName="$simpleVmName" adminUsername="$adminU" # --what-if

# Deploy all in on rg with no data disk
# az deployment group create --name mainDep --resource-group $resourceGroup --template-file main_deploy_vm_no_extra_disk.bicep --parameters vmName="$simpleVmName" adminUsername="$adminU" # --what-if

# Deploy to existing vnet but in a self contained resource group
az deployment group create --name mainDep --resource-group $resourceGroup --template-file main_deploy_vm_no_extra_disk_to_outside_vnet.bicep \
 --parameters vmName="$simpleVmName" adminUsername="$adminU" resourceGroupVnetName="$rgVnetName" virtualNetworkName="$vnet" subnetName="$subnet" #--what-if



