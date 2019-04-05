##############################################################
#               PowerShell syntactic sugar                   #
##############################################################
    # Run a basic container developed in Python and run it under some obscure web server which isn't IIS so noone should care about
docker run -d -P training/webapp python app.py

# Be more specific on the ports
docker run -d -p 80:5000 training/webapp python app.py

# Show the logs created by the container app / web server
docker logs containername

# Keep in fetching the logs
docker logs -f <container-name>

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

##############################################################
#                          Redis                             #
##############################################################
# run a new redis container
docker run -d -p 6379:6379 --name redis1 redis

# see that this container is running
docker ps

# view the log output for the container
# (should see "ready to accept connections")
docker logs redis1

# see the images we have on our computer
docker image ls

# run an interactive shell
docker exec -it redis1 sh

# some commands to try inside the shell:
ls -al # view contents of the container file system
redis-cli # start the redis CLI
ping # should respond with 'pong'
set name Alex # set a value in the cache
get name # should respond with 'Alex'
incr counter # increment (and create) a new counte
incr counter # increment it again
get counter # should respond with '2'
exit # exit from the redis CLI
exit # exit from the interactive shell

# run a second redis container, linked to the first and open an interactive shell
docker run -it --rm --link redis1:redis --name client1 redis sh

# some commands to try inside the shell
redis-cli -h redis # start the redis CLI but connect to the other container
get name # should respond with 'mark'
get counter # should respond with '2'
exit # exit from the redis CLI
exit # exit from the interactive shell

# observe that the second redis container is no longer running
docker ps

# stop the first redis container
docker stop redis1

# see all containers, even stopped ones (will only see redis1)
docker ps -a

# delete the docker redis container
docker rm redis1

# delete the redis image
docker image rm redis

##############################################################
#                         Postgre                            #
##############################################################
# start a new container running postgres with an attached volume
docker run -d -p 5432:5432 -v postgres-data:/var/lib/postgresql/data `
--name postgres1 postgres

# run an interactive shell against our container
docker exec -it postgres1 sh

# inside the shell:
createdb -U postgres mydb # create a new db
psql -U postgres mydb # connect to the db with the postgres CLI tool
CREATE TABLE people (id int, name varchar(80)); # create a table
INSERT INTO people (id,name) VALUES (1, 'Alex Mang'); # insert a row into the table
\q # exit the postgres CLI
exit # exit the interactive shell

# stop and delete the postgres1 container
docker rm -f postgres1

# check that the postgres-data volume still exists:
docker volume ls

# start a brand new container connected to the same volume
docker run -d -p 5432:5432 -v postgres-data:/var/lib/postgresql/data `
--name postgres2 postgres

# run an interactive shell against this container
docker exec -it postgres2 sh

# inside the shell
psql -U postgres mydb # connect to the db with the postgres CLI tool
SELECT * FROM people; # check that the data we entered previously is still there
\q # exit the postgres CLI
exit # exit the interactive shell

# stop delete the second container
docker rm -f postgres2

# delete the volume containing the database
docker volume rm postgres-data