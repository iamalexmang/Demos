
##############################################################
#             Image creation from a container                #
##############################################################
# Let’s start by running an interactive shell in a ubuntu container:
docker container run -ti ubuntu bash
# As you know from earlier labs, you just grabbed the image called “ubuntu” from Docker Store and are now running the bash shell inside that container.

# To customize things a little bit we will install a package called figlet in this container. Your container should still be running so type the following commands at your ubuntu container command line:
apt-get update
apt-get install -y figlet
figlet "hello world"
# You should see the words “hello docker” printed out in large ascii characters on the screen. Go ahead and exit from this container

# Now let us pretend this new figlet application is quite useful and you want to share it with the rest of your team. You could tell them to do exactly what you did above and install figlet in to their own container, which is simple enough in this example. But if this was a real world application where you had just installed several packages and run through a number of configuration steps the process could get cumbersome and become quite error prone. Instead, it would be easier to create an image you can share with your team.
# To start, we need to get the ID of this container using the ls command (do not forget the -a option as the non running container are not returned by the ls command).
docker container ls -a
# Before we create our own image, we might want to inspect all the changes we made. Try typing the command docker container diff <container ID> for the container you just created. You should see a list of all the files that were added or changed to in the container when you installed figlet. Docker keeps track of all of this information for us. This is part of the layer concept we will explore in a few minutes.
docker diff <container-ID>

# Now, to create an image we need to “commit” this container. Commit creates an image locally on the system running the Docker engine. Run the following command, using the container ID you retrieved, in order to commit the container and create an image out of it.
docker container commit <container-ID>
# That’s it - you have created your first image! 

# Once it has been commited, we can see the newly created image in the list of available images.
docker image ls

# Note that the image we pulled down in the first step (ubuntu) is listed here along with our own custom image. Except our custom image has no information in the REPOSITORY or TAG columns, which would make it tough to identify exactly what was in this container if we wanted to share amongst multiple team members.

# Adding this information to an image is known as tagging an image. From the previous command, get the ID of the newly created image and tag it so it’s named ourfiglet:
docker image tag <image-ID> ourfiglet
docker image ls

# Now we will run a container based on the newly created ourfiglet image:
docker container run ourfiglet figlet hello
# As the figlet package is present in our ourfiglet image, the command returns the following output:
# _          _ _
# | |__   ___| | | ___
# | '_ \ / _ \ | |/ _ \
# | | | |  __/ | | (_) |
# |_| |_|\___|_|_|\___/

# This example shows that we can create a container, add all the libraries and binaries in it and then commit it in order to create an image. We can then use that image just as we would for images pulled down from the Docker Store. We still have a slight issue in that our image is only stored locally. To share the image we would want to push the image to a registry somewhere. We will do that later.