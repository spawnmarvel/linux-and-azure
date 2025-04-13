$ResourceGroup = "Rg-iac-deploy-linux-fun-12"
$VMName = Get-AzVM -ResourceGroupName $ResourceGroup
$ExtensionName = "VMAccessForLinux"
$Publisher = "Microsoft.OSTCExtensions"
$ExtensionType = "VMAccessForLinux"
$TypeHandlerVersion = "1.4"
$ProtectedSettingsPath = "key.json"

Write-Host $VMName

# Verify that the key.json file exists
if (-Not (Test-Path -Path $ProtectedSettingsPath)) {
    Throw "The protected settings file '$ProtectedSettingsPath' does not exist."
}

# Read and convert the key.json content to a hashtable
$ProtectedSettings = Get-Content -Path $ProtectedSettingsPath -Raw | ConvertFrom-Json | ConvertTo-Json -Compress | ConvertFrom-Json

Set-AzVMExtension `
    -ResourceGroupName $ResourceGroup `
    -VMName $VMName `
    -Name $ExtensionName `
    -Publisher $Publisher `
    -ExtensionType $ExtensionType `
    -TypeHandlerVersion $TypeHandlerVersion `
    -Settings $PublicSettings `
    -ProtectedSettings $ProtectedSettings `
    -Location (Get-AzVM -ResourceGroupName $ResourceGroup -Name $VMName).Location