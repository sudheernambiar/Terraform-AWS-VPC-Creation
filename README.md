# VPC deployment with Terraform (AWS)
## Prerequisites 
- A EC2(Amazon-EC2) machine with Terraform installed. Role with Administrator access (full outbound traffic permitted).

## files explained
### variable.tf
- variable.tf file to define all variables in it (contains editable region, subsets(automatically chosen), sub-net bits(borrowed), two tag names(projects and owner).

### vpc.tf
- It contains needed information for the installation of the VPC in a region specified by variable, with sub-nets, route tables, NAT Gateway, Internet Gateway, sub-net association and security groups.

## Procedure Steps
### vpc.tf major points
#### Creating VPC with general values 
Enable DNS name

#### Create Sub-nets
#public1
#Enable Public IP assignements
#public2
#Enable Public IP assignements
#public3
#Enable Public IP assignements

#Private1
#Private2
#Private3

#### Create Elastic IP

#### Create IGW#
##### Create NAT-GW#

#Create RoutingTable(Public)
0.0.0.0 to IGW

#Create RoutingTable(Private)#
#0.0.0.0 to NAT GW

#RouteTableAssociation
#RT to Pub-subnet1

#RouteTableAssociation
#RT to Pub-subnet2

#RouteTableAssociation
#RT to Pub-subnet3

#RouteTableAssociation
#RT to Priv-subnet1

#RouteTableAssociation
#RT to Priv-subnet2

#RouteTableAssociation
#RT to Priv-subnet3

#Security Group for Bastin
#Public access to 22

#Security Group for WebServer
#80 from public
#22 access from bastin sg

#Security Group for MySQL
#22 access from bastin sg
#MySQL access from Webserver
