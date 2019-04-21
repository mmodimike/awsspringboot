provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "Main Vpc"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_security_group" "private_security_group" {
  name = "Bllow All Except Whitelist"
  description = "Block all inbound traffic except whitelisted Ips"
  vpc_id = "${aws_vpc.main_vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["5.22.134.100/32"] //change this value to whitelist ip
  }

  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bllow All Except Whitelist"
  }
}

resource "aws_instance" "aws_instance_web_server" {
  ami = "ami-08d658f84a6d84a80"
  instance_type = "t2.micro"
  key_name = "SuperKey"
  subnet_id = "${aws_subnet.private_subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.private_security_group.id}"]
  user_data = <<-EOF
                 #!/bin/bash
                 sudo su
                 apt-get update
                 yes | apt-get upgrade
                 yes | apt-get install default-jdk
                 wget https://s3-eu-west-1.amazonaws.com/hammodi-mike-supermike-bucket-number-one/gs-serving-web-content-0.1.0.jar
                 java -jar gs-serving-web-content-0.1.0.jar
                 EOF

  tags = {
    Name = "Spring Boot Web Application Server"
  }
}

resource "aws_eip" "elastic_ip_main_vpc" {
  instance = "${aws_instance.aws_instance_web_server.id}"
  vpc = true
}

resource "aws_internet_gateway" "main_internet_gateway" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  tags {
    Name = "Main Internet Gateway"
  }
}

resource "aws_route_table" "main_route_table" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main_internet_gateway.id}"
  }

  tags {
    Name = "Main Route Table"
  }
}

resource "aws_route_table_association" "subnet_association" {
  subnet_id      = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.main_route_table.id}"
}

resource "aws_default_network_acl" "default_network_acl" {
  default_network_acl_id = "${aws_vpc.main_vpc.default_network_acl_id}"

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

resource "aws_route53_zone" "primary" {
  name = "hammodimike.com"
}

resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "www.hammodimike.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.elastic_ip_main_vpc.public_ip}"]
}