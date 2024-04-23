az group create --name exampleRG --location uksouth

az deployment group create --resource-group exampleRG --template-file main.bicep