#                  PREREQUISITES
#   1. make sure Docker is running in Linux env mode
#   2. make sure images are already pulled - don't trust the hotel WiFi. It is evil!
#   3. make sure the PowerShell extension is installed and fully loaded in VS Code
#   4. make sure you're not listening to port 80 (netstat -a)
#   5. get a browser tab opened at https://code.msdn.microsoft.com/Getting-Started-with-221c01f5
#   6. open Azure SQL Db connections to the connection you are on
#   7. make sure Docker has a shared volume - VS Docker Tooling requires it
#   8. Service Fabric Cluster should be empty 
#   9. Open Microsoft Teams and the IoT Button channel
#   10. Delete container instance
#   11. Make sure you're logged into SalesForce

#                  DEMO 1
# Run a basic container developed in Python and run it under some obscure web server which isn't IIS so noone should care about
docker run -d -P training/webapp python app.py

# Be more specific on the ports
docker run -d -p 80:5000 training/webapp python app.py

# Show the logs created by the container app / web server
docker logs hungry_franklin

# Keep in fetching the logs
docker logs -f hungry_franklin

# Run an nginx web server without installing nginx - everyone keeps a tidy machine... and desktop!
docker run -d -p 81:80 --name webserver nginx

# Show all the containers
docker ps

# Do some PowerShell syntax stuff here. Microsoft loves it, so why not?
for ($i = 0; $i -lt 21; $i++) { docker run -d -p 80 training/webapp python app.py }

# Show those container created
docker ps

# Some more PowerShell wizardy to stop all the containers in a single shot
docker stop $(docker ps -q)

# Yup, remove all the containers
docker rm $(docker ps -q -a)

# It involves cats
docker pull amang/catweb

# It runs something which involves cats
docker run -d -p 80:5000 amang/catweb







#                  DEMO 2
# Authenticate to Azure using the Device Login method, so that the Azure CLI can run some magic
az login

# Create a new resource group. Everything in Azure starts with a Resource group
# az group create --name iglooConfAciRg --location eastus

# Create the Azure Container Registry (ACR) to hold the Azure resources
# az acr create --resource-group iglooConfAciRg --name iglooConfRegistry --sku Basic --admin-enabled true

# Authenticate over the ACR using a Docker-specific API
az acr login --name iglooConfRegistry --username iglooConfRegistry --password <password>

# Show the login server of the registry
az acr show --name iglooConfRegistry --query loginServer --output table

# Tag one of the existing images pulled down to the local Image Store
docker tag amang/catweb iglooConfRegistry.azurecr.io/catweb:igloo

# Show that the image now also exist with the "igloo" tag
docker images

# Push the tagged image to the ACR registry
docker push iglooConfRegistry.azurecr.io/catweb:igloo

# Show a list of repositoryes in the ACR registry
az acr repository list --name iglooConfRegistry --output table

# Show all the tags for the catweb image in the ACR registry
az acr repository show-tags --name iglooConfRegistry --repository catweb --output table

# What was the login server again?
az acr show --name iglooConfRegistry --query loginServer

# Show the authentication password to the ACR. Yes, it was already in the script above, but still - how does one retrieve it without opening up the Azure Portal?
az acr credential show --name iglooConfRegistry --query "passwords[0].value"

# Show what kind of magic this was...?!
az acr credential show --name iglooConfRegistry

# Create a container group, sorry instance. Make sure you're not fat-fingering the image name - Azure is kind enough to retry forever and never say a thing
az container create --name catwebcontigloo0 --image iglooconfregistry.azurecr.io/catweb:igloo --cpu 1 --memory 1 --registry-password "<password>" --ip-address public --ports 5000 -g iglooConfAciRg

# Show the public IP Address of the newly created Container Instance
az container show --name catwebcontigloo0 --resource-group iglooConfAciRg --query ipAddress.ip

# Show logs created by the container. Refresh the web page a few times and show the logs accumulating
az container logs --name catwebcontigloo0 -g iglooConfAciRg







#                  DEMO 3
# Change the web.config connection string for the Wingtip Toys app
# Server=tcp:cloudbrewdbsrv.database.windows.net,1433;Initial Catalog=cloudbrewsqldb;Persist Security Info=False;User ID=<username>;Password=<password>;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;

# Add Docker support
# Right-click the project in Visual Studio, choose Add and select Docker support

# Run and test the application

# Connect to Azure Container Registry via Docker-specific API
az acr login --name iglooConfRegistry --username iglooConfRegistry --password <password>

# Tag the Wingtip Toys image
docker tag wingtiptoys:dev iglooconfregistry.azurecr.io/wingtiptoys:1.0

# Push the Wingtip Toys image
docker push iglooconfregistry.azurecr.io/wingtiptoys:1.0

# Add Service Fabric project. Name it WingtiptoysApplication
# -  Choose type Container
#       - image: iglooconfregistry.azurecr.io/wingtiptoys:1.0
#       - name: WingtiptoysService

# Change instance count for the service in the cloud.xml parameters file

# In the Service Manifest, add the port (80) and the protocol (http) for the endpoint WingtipToysServiceTypeEndpoint

# Configure the policy in the Application Manigest
<Policies>
    <ContainerHostPolicies CodePackageRef="Code">
        <PortBinding ContainerPort="80" EndpointRef="WingtipToysServiceTypeEndpoint"/>
        <RepositoryCredentials AccountName="iglooConfRegistry"
            Password="<password>" PasswordEncrypted="false" />
    </ContainerHostPolicies>
</Policies>

# Publish application to Service Fabric Cluster

# Run and test app