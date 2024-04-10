
#Creating the VPC
resource "aws_vpc" "main"{
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  instance_tenancy = "default"

  tags = {
    Name = "Clixx VPC"
  }
}

#Creating public subnet
resource "aws_subnet" "Bastion-pub_subnet" {
 count      = length(var.azs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.Bastion-pub-subnet-cidrs, count.index)
 availability_zone = element(var.azs, count.index)#######
 map_public_ip_on_launch = true
 
 tags = {
   Name = "Bastion Public Subnet ${count.index + 1}"##############
 }
}

#Creating the private subnet
resource "aws_subnet" "clixx-prvt_subnet" {
 count      = length(var.azs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.clixx-prvt-subnet-cidrs, count.index)
 availability_zone = element(var.azs, count.index)#######
 
 tags = {
   Name = "Private Subnet ${count.index + 1}"##########
 }
}

#Creating the private subnet for RDS Database
resource "aws_subnet" "RDS-prvt_subnet" {
 count      = length(var.azs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.RDS-prvt-subnet-cidrs, count.index)
 availability_zone = element(var.azs, count.index)#######
 
 tags = {
   Name = "RDS Private Subnet ${count.index + 1}"##########
 }
}


#Creating the private subnet for Oracle DB
resource "aws_subnet" "Oracle-prvt_subnet" {
 count      = length(var.azs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.Oracle-prvt-subnet-cidrs, count.index)
 availability_zone = element(var.azs, count.index)#######
 
 tags = {
   Name = "Oracle Private Subnet ${count.index + 1}"##########
 }
}

#Creating the private subnet for Java
resource "aws_subnet" "Java-prvt_subnet" {
 count      = length(var.azs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.Java-prvt-subnet-cidrs, count.index)
 availability_zone = element(var.azs, count.index)#######
 
 tags = {
   Name = "Java Private Subnet ${count.index + 1}"##########
 }
}

#Creating the private subnet for Vacant Private subnet
resource "aws_subnet" "Xtra-prvt_subnet" {
 count      = length(var.azs)
 vpc_id     = aws_vpc.main.id
 cidr_block = element(var.Xtra-prvt-subnet-cidrs, count.index)
 availability_zone = element(var.azs, count.index)#######
 
 tags = {
   Name = "Xtra Private Subnet ${count.index + 1}"##########
 }
}





#Creating Internet gateway
resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.main.id
 
 tags = {
   Name = "Project VPC IGW"
 }
}

#Creating the eip
resource "aws_eip" "NATGatewayEIP" {
  count = length(var.azs) 
  domain = "vpc"
  tags = {
    "Name"  = "ClixxNAT"
  }
}


#Creating the nat gateway
resource "aws_nat_gateway" "nat" {
  count = length(var.azs)
  allocation_id = aws_eip.NATGatewayEIP[count.index].id
  subnet_id     = aws_subnet.Bastion-pub_subnet[count.index].id 
}



#Creating public route table
resource "aws_route_table" "public_rt" {
  count = length(var.azs)
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
    
  }
  tags = {
    Name = "Bast Public Route Table ${count.index + 1}"
  }
}


#Creating the route table for private subnet for App server
resource "aws_route_table" "private_rt" {

  vpc_id = aws_vpc.main.id
   count = length(var.azs)
  
  tags = {
    Name = " Clixx Private Route Table"
  }
}
 
#Directing traffic from priv subnet to the NAT gateway
resource "aws_route" "priv_internet_access" {
  route_table_id = aws_route_table.private_rt[count.index].id
  count = length(var.azs)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat[count.index].id
}


# Create private route table associations
resource "aws_route_table_association" "private_associations" {
  count         = length(var.azs)
  subnet_id     = aws_subnet.clixx-prvt_subnet[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}


# Create public route table associations for NAT gateway route table
resource "aws_route_table_association" "public_associations" {
  count         = length(var.azs)
  subnet_id     = aws_subnet.Bastion-pub_subnet[count.index].id
  route_table_id = aws_route_table.public_rt[count.index].id
}


# # Create the security group using the defined rules for VPC.
# resource "aws_security_group" "my_security_group" {
#   name        = "my-security-group"
#   description = "My Security Group"
#   vpc_id      = aws_vpc.main.id  

#   dynamic "ingress" {
#     for_each = var.ingress_rules

#     content {
#       from_port   = ingress.value.from_port
#       to_port     = ingress.value.to_port
#       protocol    = ingress.value.protocol
#       cidr_blocks = ingress.value.cidr_blocks
#     }
#   }
#  dynamic "egress" {
#     for_each = var.egress_rules

#     content {
#       from_port   = egress.value["from_port"]
#       to_port     = egress.value["to_port"]
#       protocol    = egress.value["protocol"]
#       cidr_blocks = egress.value["cidr_blocks"]
#     }
#   }

# }