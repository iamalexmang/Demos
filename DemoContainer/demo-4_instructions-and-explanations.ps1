##############################################################
#             Image creation from a Dockerfile               #
##############################################################
# Dockerfiles can be managed the same way you might manage source code: they are simply text files so almost any version control system can be used to manage Dockerfiles over time.

# We will use a simple example in this section and build a “hello world” application in Node.js. Do not be concerned if you are not familiar with Node.js: Docker (and this exercise) does not require you to know all these details.

# We will start by creating a file in which we retrieve the hostname and display it. NOTE: You should be at the Docker host’s command line ($). If you see a command line that looks similar to root@abcd1234567:/# then you are probably still inside your ubuntu container from the previous exercise. Type exit to return to the host command line.

# Type the following content into a file named index.js. You can use vi, vim or several other Linux editors in this exercise.
var os = require("os");
var hostname = os.hostname();
console.log("hello from " + hostname);

# The file we just created is the javascript code for our server. As you can probably guess, Node.js will simply print out a “hello” message. We will Docker-ize this application by creating a Dockerfile. We will use alpine as the base OS image, add a Node.js runtime and then copy our source code in to the container. We will also specify the default command to be run upon container creation.

# Create a file named Dockerfile and copy the following content into it.
    FROM alpine
    RUN apk update && apk add nodejs
    COPY . /app
    WORKDIR /app
    CMD ["node","index.js"]


# Let’s build our first image out of this Dockerfile and name it hello:v0.1:
docker image build -t hello:v0.1 .

# We then start a container to check that our applications runs correctly:
docker container run hello:v0.1

# What just happened? We created two files: our application code (index.js) is a simple bit of javascript code that prints out a message. And the Dockerfile is the instructions for Docker engine to create our custom container. This Dockerfile does the following:
# 1. Specifies a base image to pull FROM - the alpine image we used in earlier labs.
# 2. Then it RUNs two commands (apk update and apk add) inside that container which installs the Node.js server.
# 3. Then we told it to COPY files from our working directory in to the container. The only file we have right now is our index.js.
# 4. Next we specify the WORKDIR - the directory the container should use when it starts up
# 5. And finally, we gave our container a command (CMD) to run when the container starts.

# Recall that in previous labs we put commands like echo "hello world" on the command line. With a Dockerfile we can specify precise commands to run for everyone who uses this container. Other users do not have to build the container themselves once you push your container up to a repository (which we will cover later) or even know what commands are used. The Dockerfile allows us to specify how to build a container so that we can repeat those steps precisely everytime and we can specify what the container should do when it runs

##############################################################
#                       Image layers                         #
##############################################################
# There is something else interesting about the images we build with Docker. When running they appear to be a single OS and application. But the images themselves are actually built in layers. If you scroll back and look at the output from your docker image build command you will notice that there were 5 steps and each step had several tasks. You should see several “fetch” and “pull” tasks where Docker is grabbing various bits from Docker Store or other places. These bits were used to create one or more container layers. Layers are an important concept. To explore this, we will go through another set of exercise

# First, check out the image you created earlier by using the history command (remember to use the docker image ls command from earlier exercises to find your image IDs):
docker image history <image-ID>

# What you see is the list of intermediate container images that were built along the way to creating your final Node.js app image. Some of these intermediate images will become layers in your final container image. In the history command output, the original Alpine layers are at the bottom of the list and then each customization we added in our Dockerfile is its own step in the output. This is a powerful concept because it means that if we need to make a change to our application, it may only affect a single layer! 

# Type the following in to your console window:
echo "console.log(\"this is v0.2\");" >> index.js

# This will add a new line to the bottom of your index.js file from earlier so your application will output one additional line of text. Now we will build a new image using our updated code. We will also tag our new image to mark it as a new version so that anybody consuming our images later can identify the correct version to use:
docker image build -t hello:v0.2 .

# Notice something interesting in the build steps this time. In the output it goes through the same five steps, but notice that in some steps it says Using cache.

# Docker recognized that we had already built some of these layers in our earlier image builds and since nothing had changed in those layers it could simply use a cached version of the layer, rather than pulling down code a second time and running those steps. Docker’s layer management is very useful to IT teams when patching systems, updating or upgrading to the latest version of code, or making configuration changes to applications. Docker is intelligent enough to build the container in the most efficient way possible, as opposed to repeatedly building an image from the ground up each and every time

##############################################################
#                    Image inspection                        #
##############################################################
# Now let us reverse our thinking a bit. What if we get a container from Docker Store or another registry and want to know a bit about what is inside the container we are consuming? Docker has an inspect command for images and it returns details on the container image, the commands it runs, the OS and more.
docker image inspect alpine

# There is a lot of information in there:
# - the layers the image is composed of
# - the driver used to store the layers
# - the architecture / OS it has been created for
# - metadata of the image
# - …

# We will not go into all the details here but we can use some filters to just inspect particular details about the image. You may have noticed that the image information is in JSON format. We can take advantage of that to use the inspect command with some filtering info to just get specific data from the image.

# Let’s get the list of layers:
docker image inspect --format "{{ json .RootFS.Layers }}" alpine

# Alpine is just a small base OS image so there’s just one layer ["sha256:60ab55d3379d47c1ba6b6225d59d10e1f52096ee9d5c816e42c635ccc57a5a2b"]

# New let’s look at our custom Hello image. You will need the image ID (use docker image ls if you need to look it up):
docker image inspect --format "{{ json .RootFS.Layers }}" <image ID>

# We have three layers in our application. Recall that we had the base Alpine image (the FROM command in our Dockerfile), then we had a RUN command to install some packages, then we had a COPY command to add in our javascript code. Those are our layers! If you look closely, you can even see that both alpine and hello are using the same base layer, which we know because they have the same sha256 hash.

# The tools and commands we explored in this lab are just the beginning. Docker Enterprise Edition includes private Trusted Registries with Security Scanning and Image Signing capabilities so you can further inspect and authenticate your images. In addition, there are policy controls to specify which users have access to various images, who can push and pull images, and much more.

# Another important note about layers: each layer is immutable. As an image is created and successive layers are added, the new layers keep track of the changes from the layer below. When you start the container running there is an additional layer used to keep track of any changes that occur as the application runs (like the “hello.txt” file we created in the earlier exercises). This design principle is important for both security and data management. If someone mistakenly or maliciously changes something in a running container, you can very easily revert back to its original state because the base layers cannot be changed. Or you can simply start a new container instance which will start fresh from your pristine image.

##############################################################
#                       Azure usage                          #
##############################################################
# Authenticate to Azure using the Device Login method, so that the Azure CLI can run some magic
az login #d012

# Create a new resource group. Everything in Azure starts with a Resource group
# az group create --name techoramaRg --location eastus #d013

# Create the Azure Container Registry (ACR) to hold the Azure resources
# az acr create --resource-group techoramaRg --name techoramaRegistry --sku Basic --admin-enabled true #d014

# Authenticate over the ACR using a Docker-specific API
# az acr login --name techoramaRegistry --username techoramaRegistry --password <password> #d015

# Show the login server of the registry
az acr show --name techoramaRegistry --query loginServer --output table #d016

# Tag one of the existing images pulled down to the local Image Store
docker tag amang/catweb techoramaRegistry.azurecr.io/catweb:techorama #d017

# Show that the image now also exist with the "igloo" tag
docker images #d018

# Push the tagged image to the ACR registry
docker push techoramaRegistry.azurecr.io/catweb:techorama #d019

# Show a list of repositoryes in the ACR registry
az acr repository list --name techoramaRegistry --output table #d020

# Show all the tags for the catweb image in the ACR registry
az acr repository show-tags --name techoramaRegistry --repository catweb --output table #d021

# What was the login server again?
az acr show --name techoramaRegistry --query loginServer

# Show the authentication password to the ACR. Yes, it was already in the script above, but still - how does one retrieve it without opening up the Azure Portal?
az acr credential show --name techoramaRegistry --query "passwords[0].value" #d022

# Show what kind of magic this was...?!
az acr credential show --name techoramaRegistry #d023

# Create a container group, sorry instance. Make sure you're not fat-fingering the image name - Azure is kind enough to retry forever and never say a thing
az container create --name catwebconttechonl --image techoramaRegistry.azurecr.io/catweb:techorama --cpu 1 --memory 1 --registry-password "<password>" --ip-address public --ports 5000 -g techoramaRg --registry-usernam
e techoramaRegistry --registry-login-server techoramaregistry.azurecr.io #d024

# Show the public IP Address of the newly created Container Instance
az container show --name catwebconttechonl --resource-group techoramaRg --query ipAddress.ip #d025

# Show logs created by the container. Refresh the web page a few times and show the logs accumulating
az container logs --name catwebconttechonl -g techoramaRg #d026
