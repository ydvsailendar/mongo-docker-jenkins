# fusemachines tasks process documentation MongoDB setup and configuration:

## Task 1: Setup and configure a MongoDB on your local system

### Install the latest stable version of MongoDB on your local system and Your MongoDB installation should run on background:

####  Visit [mongo installation](https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/) or follow below steps:

1.  Import the MongoDB public GPG Key `wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -` The operation should respond with an OK.

2. However, if you receive an error indicating that gnupg is not installed, you can:
`sudo apt-get install gnupg` 

3. Create the *_/etc/apt/sources.list.d/mongodb-org-5.0.list_* file for Ubuntu x version The example below follow Ubuntu 20.04 (Focal):
`echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list` 

4. Reload local package database: `sudo apt-get update`

5. Install the MongoDB packages as mentioned in the task but you can also install specific release of MongoDB:
`sudo apt-get install -y mongodb-org`

6. Few commands for unintendend upgrades:
   
- `echo "mongodb-org hold" | sudo dpkg --set-selections`
- `echo "mongodb-org-database hold" | sudo dpkg --set-selections`
- `echo "mongodb-org-server hold" | sudo dpkg --set-selections`
- `echo "mongodb-org-shell hold" | sudo dpkg --set-selections`
- `echo "mongodb-org-mongos hold" | sudo dpkg --set-selections`
- `echo "mongodb-org-tools hold" | sudo dpkg --set-selections`

7. The guide follows the systemd(systemctl implemetation).
   
8. Start MongoDB: `sudo systemctl start mongod`

9. If you receive an error similar to the following when starting mongod: *_Failed to start mongod.service: Unit mongod.service not found._*

10. Run the following command first: `sudo systemctl daemon-reload`

11. Verify that MongoDB has started successfully: `sudo systemctl status mongod`

12. Stop MongoDB: `sudo systemctl stop mongod`

13. Restart MongoDB: `sudo systemctl restart mongod`
14. Begin using MongoDB: `mongo`

### Your MongoDB application should restart in case of any process failure. (Preferably monitored by some process monitoring tool eg. Systemd)

- Add `Restart=always` to `/lib/systemd/system/mongod.service` file under [Service].

- After adding the lines do: `sudo systemctl daemon-reload`

- To kill the server run following commands:
- `mongo`
- `use admin`
- `db.shutdownServer()` 

- Check status of server uptime to verify: `sudo systemctl status mongod`

## Task 2: Previledges and Access

### On the same installation create two different databases, with 3 different permissions and sets with a strong password

1. Creating a MongoDB Database with the CLI (the MongoDB shell) and insert data to collections inside 2 databases
   - `mongo`
   - `show dbs` to list database
   - `use first_database`
   - switches context
   -  show dbs only shows this database when document is added to it to check which db you are using do `db` which will list the current context which will be as of now first_database from the above command 
   - Insert document to *_first_database_* under *_users_* collection `db.users.insertMany([{name: "samir", age: 12, gender: "male"}, {name: "sima", age: 13, gender: "female"}])`
   - to create a second database do
   - `use second_database`
   - switches context
   - show dbs only shows this database when document is added to it to check which db you are using do `db` which will list the current context which will be as of now second_database from the above command
   - Insert document to *_first_database_* under *_products_* collection `db.products.insertMany([{name: "car", cost: 120000, model: "bmw"}, {name: "bus", cost: 130000, model: "tata"}])`

2. 3 different permissions and sets with a strong password
   - Switch database to first_database do `use first_database`
   - Create Admin user with admin permission on the 2 databases `db.createUser({user: "admin", pwd: "iamadmin1@#", roles: [{role: "dbAdmin", db: "second_database"}, "dbAdmin"]})`
   - Create read user with read permission on the first_database `db.createUser({user: "read", pwd: "iamread1@#", roles: ["read"]})`
   - Switch database to second_database do `use second_database`
   - Create readWrite user with readWrite permission on the second_database `db.createUser({user: "readWrite", pwd: "iamreadWrite1@#", roles: ["readWrite"]})`

The above concludes the db operations and steps.

# fusemachines tasks process documentation Docker and MongoDB:

## Task 1: Database
### To test the working of the mongodb in the local system with user role we need to do the following the database configuration step follows the first task database integration:
- edit `/etc/mongod.conf`
- under security add `authorization: enabled`
- Restart mongo server using `sudo service mongodb restart`
- There are 3 api one for fetch 2 for posting to each databases
  - `local_server_url/api` [GET] returns users from first database and products from second database
  - `local_server_url/api/add/user` [POST] returns error message showing permission issues when used read role to write on first_database
  - `local_server_url/api/add/product` [POST] returns product id of the newly added document to second_database inside products collection

## Task 2: Docker
- [Install Docker](https://docs.docker.com/engine/install/ubuntu/)
### python application is inside the app folder
### Use multi-stage build to write the Dockerfile [in dockerfile]
- as the mongod instance is standalone and running in local machine
- i had to run the docker on the host network to achieve for that i added flag of `--net=host` on the docker run command for this and also updated the mongo connection string from localhost to my ip address so you will be needing to do the same
- to login to docker do `docker login`
- To build the docker image run `docker build -t ydvsailendar/task:latest .`
- To run the image locally do `docker run --net=host  -p 5000:5000 -it ydvsailendar/task:latest`

## Task 3: Deployment
### Install/Configure Jenkins on your local system
- Jenkins LTS installtion steps:
  - `wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -`
  - `sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
    /etc/apt/sources.list.d/jenkins.list'`
  - `sudo apt-get update`
  - `sudo apt-get install jenkins`

- Install JDK
  - `sudo apt update`
  - `sudo apt search openjdk`
  - `sudo apt install openjdk-11-jdk`
  - `java -version`

- Register the Jenkins service `sudo systemctl daemon-reload`
- start the Jenkins service `sudo systemctl start jenkins`
- check the status of the Jenkins service `sudo systemctl status jenkins`
- Unlocking Jenkins
  - When you first access a new Jenkins instance, you are asked to unlock it using an automatically-generated password.
  - Browse to http://localhost:8080 (or whichever port you configured for Jenkins when installing it) and wait until the Unlock Jenkins page appears.
  - The command: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword` will print the password at console.
  
- Customizing Jenkins with plugins
  - install suggested plugins 

- Creating the first administrator user
- Go to create item and give a name, select pipeline and hit ok
- under pipeline definition select *_Pipeline script from SCM_* enter [the github url](https://github.com/ydvsailendar/mongo-docker-jenkins), select *_master_* branch and Jenkinsfile and save.
- run build and go [here](http://localhost:5000) to test the image and the task
- to remove the local container and images do
- `docker stop $(docker ps -a -q) -t 10`
- `docker rm $(docker ps -a -q)`
- The build is currently manual as with every changes you will have to manually go the the jenkins dashboard and run the build.