# Enter 
az login --tenant
#Deploy
bash deploy.sh
#vars
rgName=""
vmName=""
#
echo $rgName
# list all
az resource list --resource-group $rgName
az resource list --resource-group $rgName --query [].name

# get IP address
az vm list-ip-addresses --resource-group $rgName --name $vmName --output table
# n and p
uName=""
newPass="" 
# You must iterate newPass this or change it before running below
az vm user update --resource-group $rgName --name $vmName --username $uName --password $newPass
# enter it
ssh user@ipaddress

