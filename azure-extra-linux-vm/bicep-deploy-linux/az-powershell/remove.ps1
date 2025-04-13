$resourceGroup = "Rg-iac-deploy-linux-fun-12"

Get-AzResourceGroup -Name $resourceGroup | Remove-AzResourceGroup -Force -AsJob