data "aws_availability_zones" "myaz" {
  state = "available"
}

output "az1" {
  value = data.aws_availability_zones.myaz.names[0]
}

output "az2" {
  value = data.aws_availability_zones.myaz.names[1]
}

output "az3" {
  value = data.aws_availability_zones.myaz.names[2]
}

#Create VPC#
#Enable DNS name#
resource "aws_vpc" "VPC" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
   tags = {
    Name = "${var.project}-VPC-${var.env}"
    Admin = var.owner
    Environment = var.env
  } 
}

#####Create Subnets#
#public1
#Enable Public IP assignements
resource "aws_subnet" "pub1" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = cidrsubnet(var.vpc_cidr, var.bits, 0) 
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.myaz.names[0]

  tags = {
   Name = "${var.project}-PublicSubnet1-${var.env}"
   Admin = var.owner
   Environment = var.env
  } 
}
#public2
#Enable Public IP assignements
resource "aws_subnet" "pub2" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = cidrsubnet(var.vpc_cidr, var.bits, 1)
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.myaz.names[1]
  
  tags = {
   Name = "${var.project}-PublicSubnet2-${var.env}"
   Admin = var.owner
   Environment = var.env
  } 
}
#public3
#Enable Public IP assignements
resource "aws_subnet" "pub3" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = cidrsubnet(var.vpc_cidr, var.bits, 2)
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.myaz.names[2]
  
  tags = {
   Name = "${var.project}-PublicSubnet3-${var.env}"
   Admin = var.owner
   Environment = var.env
  } 
}
#Private1
resource "aws_subnet" "prv1" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = cidrsubnet(var.vpc_cidr, var.bits, 3)
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.myaz.names[0]
  
  tags = {
   Name = "${var.project}-PrivateSubnet1-${var.env}"
   Admin = var.owner
   Environment = var.env
  } 
}
#Private2
resource "aws_subnet" "prv2" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = cidrsubnet(var.vpc_cidr, var.bits, 4)
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.myaz.names[1]
  
  tags = {
   Name = "${var.project}-PrivateSubnet2-${var.env}"
   Admin = var.owner
   Environment = var.env
  } 
}
#Private3
resource "aws_subnet" "prv3" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = cidrsubnet(var.vpc_cidr, var.bits, 5)
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.myaz.names[2]
  
  tags = {
   Name = "${var.project}-PrivateSubnet3-${var.env}"
   Admin = var.owner
   Environment = var.env
  } 
}
#####Create Elastic IP#
resource "aws_eip" "NAT-EIP" {
  vpc      = true
}
#####Create IGW#
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id

   tags = {
    Name = "${var.project}-IGW-${var.env}"
    Admin = var.owner
    Environment = var.env
  } 
}
#####Create NAT-GW#
resource "aws_nat_gateway" "NAT-GW" {
  allocation_id = aws_eip.NAT-EIP.id
  subnet_id     = aws_subnet.pub1.id

   tags = {
    Name = "${var.project}-NAT-${var.env}"
    Admin = var.owner
    Environment = var.env
  } 
  depends_on = [aws_internet_gateway.IGW]
}
#####Create RoutingTable(Public)#
#0.0.0.0 to IGW
resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

   tags = {
    Name = "${var.project}-PUB-RT-${var.env}"
    Admin = var.owner
    Environment = var.env
  } 
}
#####Create RoutingTable(Private)#
#0.0.0.0 to NAT GW
resource "aws_route_table" "priv-rt" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT-GW.id
  }

   tags = {
    Name = "${var.project}-PRIV-RT-${var.env}"
    Admin = var.owner
    Environment = var.env
  } 
}
#####RouteTableAssociation
#RT to Pub-subnet1
resource "aws_route_table_association" "pub1" {
  subnet_id      = aws_subnet.pub1.id
  route_table_id = aws_route_table.pub-rt.id
}

#RT to Pub-subnet2
resource "aws_route_table_association" "pub2" {
  subnet_id      = aws_subnet.pub2.id
  route_table_id = aws_route_table.pub-rt.id
}

#RT to Pub-subnet3
resource "aws_route_table_association" "pub3" {
  subnet_id      = aws_subnet.pub3.id
  route_table_id = aws_route_table.pub-rt.id
}

#RT to Priv-subnet1
resource "aws_route_table_association" "priv1" {
  subnet_id      = aws_subnet.prv1.id
  route_table_id = aws_route_table.priv-rt.id
}

#RT to Priv-subnet2
resource "aws_route_table_association" "priv2" {
  subnet_id      = aws_subnet.prv2.id
  route_table_id = aws_route_table.priv-rt.id
}

#RT to Priv-subnet3
resource "aws_route_table_association" "priv3" {
  subnet_id      = aws_subnet.prv3.id
  route_table_id = aws_route_table.priv-rt.id
}
#####Create Security Groups
#Security Group for Bastin
#Public access to 22
resource "aws_security_group" "bastien" {
  name        = "Basien-sg"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.VPC.id

  ingress {
    description      = "Ssh from public"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

 tags = {
    Name = "${var.project}-BASTIEN-SG-${var.env}"
    Admin = var.owner
    Environment = var.env
  } 
}
#Security Group for WebServer
#22 access from bastin sg
#Public access to 80
resource "aws_security_group" "webserver" {
  name        = "Webserver-sg"
  description = "Allow 80 inbound traffic"
  vpc_id      = aws_vpc.VPC.id

  ingress {
    description      = "PublicAccess"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "ssh from bastien"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [ aws_security_group.bastien.id ]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

 tags = {
    Name = "${var.project}-WEBSERVER-SG-${var.env}"
    Admin = var.owner
    Environment = var.env
  } 
}

#Security Group for MySQL
#22 access from bastin sg
#MySQL access from Webserver
resource "aws_security_group" "MySQL" {
  name        = "MySQL-sg"
  description = "Allow 3306 n 22 inbound traffic"
  vpc_id      = aws_vpc.VPC.id

  ingress {
    description      = "mysql from webserver"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [ aws_security_group.webserver.id ]
  }

  ingress {
    description      = "ssh from bastien"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [ aws_security_group.bastien.id ]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

 tags = {
    Name = "${var.project}-MySQL-SG-${var.env}"
    Admin = var.owner
    Environment = var.env
  } 
}