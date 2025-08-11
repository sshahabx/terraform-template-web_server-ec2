variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {
  default = "us-east-1"
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# creating a virtual private network

resource "aws_vpc" "prod-vpc" {
    cidr_block= "10.0.0.0/16"

    tags = {
        Name = "production"
    }

    
}

# Creating an internet gateway
resource "aws_internet_gateway" "gw"{

    vpc_id=aws_vpc.prod-vpc.id

    
    tags = {
        Name = "production"
    }

}
 


# Creating a Custom Route Table 
resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    # sends traffic coming from this to IG
    # cidr_block = "10.0.1.0/24"

    # all traffic should go to the route
    cidr_block= "0.0.0.0/0"


    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "production"
  }
}

# Creating a Subnet
# here will be the webserver

resource "aws_subnet" "subnet-1"{
    vpc_id= aws_vpc.prod-vpc.id
    cidr_block= "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name= "prod-subnet"
    }
}

# Now associating this subnet with the route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.route-table.id
}

# Creating a Security group to allow traffic to 22, 80, 443

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    # - 1 means any port
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# create a network interface

resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}

# assigning an elastic IP so anyone can acceess it on internet
# ip depends on a gateway so inorder to have an eip u need an internet gateway

resource "aws_eip" "lb" {
  network_interface = aws_network_interface.web-server-nic.id
  associate_with_private_ip= "10.0.1.50"
  depends_on= [aws_internet_gateway.gw,aws_instance.web-server]
  domain = "vpc"
}

# creating an ubuntu server
# install/enable apache

resource "aws_instance" "web-server"{

    ami = "ami-020cba7c55df1f615"
    instance_type= "t2.micro"
    availability_zone="us-east-1a"
    key_name= "admin-r3dhat"
    network_interface{
        device_index=0
        network_interface_id= aws_network_interface.web-server-nic.id

    }

    user_data = <<-EOF
                #! /bin/bash
                sudo apt update -y
                sudo apt install apache2 -y    
                sudo systemctl start apache2
                sudo bash -c "echo terraform works! > /var/www/html/index.html"
                EOF

    tags = {
        Name = "web-server"
    }
}

 

