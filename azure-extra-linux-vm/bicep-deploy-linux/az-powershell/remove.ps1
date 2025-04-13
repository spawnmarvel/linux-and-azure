$resourceGroup = "Rg-iac-linux-fu-0991"

Get-AzResourceGroup -Name $resourceGroup | Remove-AzResourceGroup -Force -AsJob