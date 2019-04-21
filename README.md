# Simple Springboot applicaiton over AWS

This code aims to meet the following requirements:
•	Create a linux virtual machine
•	Bootstrap the host with Java
•	Deploy a helloworld springboot application on the host using a shell script (bootable)
•	The app should be accessible from a specific IP only
•	Process documentation should be submitted as well.


# Thought process & High level design
*Creating the needed infra using terraform*
- 
- Create VPC to host our resources, and create subnet within VPC.
- "Place" the EC2 instance within our subnet
- Provide EC2 instance with elastic IP for remote access
- Create internet access to subnet
  - Add internet gateway
  - Add route table
  - associate our route table with our subnet
- Instead of creating new network access control list, use the defult NACL which is already configured to allow all traffic in/out
- Create a new A record attaching elastic IP to domain 

*Creating dependancy infra using amazon console*
- 
- Create a public S3 bucket which will contain the .jar file being downloaded upon bootstrap
- Create a domain name


*Creating the needed application*
- 
- download spring tool suite for quick start with spring boot app
- instance default "hello world" project
- download appache maven
- build .jar file
- upload .jar file to our static S3 bucket 

*Creating the bootstrap script*
- 
- switch to root user & install ubuntu updates & upgrades
- install JAVA default jdk to provide a runtime environemt for our springboot app 
- download the .jar from our S3 bucket
- run the application




