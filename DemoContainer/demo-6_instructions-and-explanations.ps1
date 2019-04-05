##############################################################
#                     CI/CD Web Apps                         #
##############################################################

# Log in to Azure CLI
az login

# Create a resource group in our preferred location to use
$resourceGroup = "rubrikk_demowebcont_rg" # change with your own resource group name
$location = "westeurope" # change with your preferred location
az group create -l $location -n $resourceGroup # creates a new resource group

# Create an app service plan to host
$planName = "rubrikk_appservplan" # change with your preferred service plan name
az appservice plan create -n $planName -g $resourceGroup -l $location `
                          --is-linux --sku S1 # 

# n.b. Can't use anything but docker hub here because of a current Azure CLI handicap
# so we have to arbitrarily pick a runtime --runtime "node|6.2" or a public image like scratch
$appName="rubrikk-cicd" # this is the prefexis of the web app's FQDN ([...].azurewebsites.net), so change it to something globally unique
az webapp create -n $appName -g $resourceGroup --plan $planName -i "scratch" # create a new web app for containers

$acrName = "rubrikkregistry" # change with your own registry name (it was created in a previous demo session)
$acrLoginServer = az acr show -n $acrName --query loginServer -o tsv
$acrUserName = az acr credential show -n $acrName --query username -o tsv
$acrPassword = az acr credential show -n $acrName --query passwords[0].value -o tsv

# https://github.com/Azure/azure-cli/pull/3888/files - maybe don't need creds?
az webapp config container set -n $appName -g $resourceGroup `
                               -c "$acrLoginServer/catweb:latest" `
                               -r "https://$acrLoginServer" `
                               -u $acrUserName -p $acrPassword

az webapp show -n $appName -g $resourceGroup --query "defaultHostName" -o tsv

# create a staging slot (cloning from production slot's settings)
az webapp deployment slot create -g $resourceGroup -n $appName `
                                 -s staging --configuration-source $appName

az webapp show -n $appName -g $resourceGroup -s staging --query "defaultHostName" -o tsv

# enable CD for the staging slot
az webapp deployment container config -g $resourceGroup -n $appName `
                                      -s staging --enable-cd true

# get the webhook
$cicdurl = az webapp deployment container show-cd-url -s staging `
                     -n $appName -g $resourceGroup --query CI_CD_URL -o tsv

# to configure the webhook on an ACR registry
$webHookName = "myacrwebhook"
az acr webhook create --registry $acrName --name myacrwebhook --actions push `
                      --uri $cicdurl

# ACTION ITEM
# TODO Change the image locally (maybe change the HTML document to a different title?)

# Push the new version of our app to the ACR
docker push rubrikkregistry.azurecr.io/catweb:latest

# Perform a slot swap
az webapp deployment slot swap -g $resourceGroup -n $appName `
                               --slot staging --target-slot production

# Clean up
az group delete --name $resourceGroup --yes --no-wait

# delete the webhook
az acr webhook delete --registry $acrName --name myacrwebhook